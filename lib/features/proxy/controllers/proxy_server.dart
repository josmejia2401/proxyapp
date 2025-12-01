import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:proxyapp/features/proxy/dns/dns_resolver.dart';

import 'client_tracker.dart';
import 'proxy_notifier.dart';

class ProxyServer {
  ServerSocket? _server;
  final ClientTracker tracker;
  final ProxyNotifier notifier;

  ProxyServer(this.tracker, this.notifier);

  bool get isRunning => _server != null;

  Future<void> start({required int port}) async {
    notifier.addLog("Iniciando servidor proxy en puerto $port...");
    try {
      _server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
        backlog: 1024,  // default era 128
      );

      notifier.onServerStarted();

      _server!.listen(
        _handleClient,
        onError: _onServerError,
        onDone: () {
          notifier.onServerStopped();
        },
      );
    } catch (e) {
      debugPrint("Error al iniciar proxy: $e");
      notifier.addLog("❌ ERROR al iniciar: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _server?.close();
      _server = null;
      notifier.addLog("Proxy detenido correctamente.");

      notifier.onServerStopped();
    } catch (e) {
      debugPrint("Error al detener proxy: $e");
      notifier.addLog("❌ ERROR al detener: $e");
    }
  }

  void _onServerError(dynamic error) {
    debugPrint("Proxy error: $error");
    notifier.addLog("🔥 ERROR del servidor: $error");
  }

  Future<void> _handleClient(Socket client) async {
    client.setOption(SocketOption.tcpNoDelay, true);

    final ip = client.remoteAddress.address;
    final port = client.remotePort;

    if (notifier.isBlocked(ip)) {
      client.write("HTTP/1.1 403 Forbidden\r\n\r\n");
      client.close();
      return;
    }

    final mac = await _resolveMac(ip);
    final deviceName = await _resolveDeviceName(ip);

    tracker.registerConnection(
      ip,
      macAddress: mac,
      deviceName: deviceName,
      port: port,
    );

    List<int> buffer = [];
    bool firstPacket = true;
    Socket? remote;

    client.listen(
      (data) async {



        if (firstPacket) {
          firstPacket = false;
          tracker.incrementActiveRequests();

          buffer.addAll(data);

          final requestStr = utf8.decode(buffer, allowMalformed: true);
          final firstLine = requestStr.split("\r\n").first;

          final userAgent = _extractHeader(requestStr, "User-Agent");

          tracker.updateClientMeta(
            ip,
            firstLine: firstLine,
            userAgent: userAgent,
          );

          if (firstLine.startsWith("CONNECT")) {
            await _handleConnectTunnel(
              client,
              firstLine,
              ip,
              outRemoteSocket: (s) {
                remote = s;
              },
            );
            return;
          }

          await _handleHttpRequest(client, requestStr, firstLine, ip);
          return;
        }

        if (remote != null) {
          remote!.add(data);
          tracker.addUpload(ip, data.length);
        }
      },
      onDone: () {
        tracker.decrementActiveRequests();
        tracker.registerDisconnect(ip);
        remote?.close();
        client.close();
      },
      onError: (e) {
        notifier.addLog("❌ Error en cliente $ip: $e");
        tracker.decrementActiveRequests();
        tracker.registerDisconnect(ip);
        remote?.close();
        client.close();
      },
      cancelOnError: true,
    );
  }

  Future<void> _handleConnectTunnel(
    Socket client,
    String firstLine,
    String ip, {
    required Function(Socket) outRemoteSocket,
  }) async {
    try {
      final parts = firstLine.split(" ");
      final host = parts[1].split(":")[0];
      final port = int.parse(parts[1].split(":")[1]);

      if (notifier.firewall.isBlocked(host: host, url: "$host:$port")) {
        client.write("HTTP/1.1 403 Forbidden\r\n\r\n");
        client.close();
        return;
      }

      final ipToConnect = await DnsResolver.instance.resolve(host);

      final remote = await Socket.connect(ipToConnect, port);
      outRemoteSocket(remote);

      client.write("HTTP/1.1 200 Connection Established\r\n\r\n");

      remote.listen(
        (data) {
          try {
            client.add(data);
            tracker.addDownload(ip, data.length);
          } catch (e) {
            notifier.addLog("❌ Error REMOTO→CLIENTE: $e");
          }
        },
        onDone: () {
          client.close();
        },
        onError: (e) {
          notifier.addLog("❌ Error remoto túnel: $e");
          client.close();
        },
        cancelOnError: true,
      );
    } catch (e) {
      notifier.addLog("❌ ERROR CONNECT ($ip) → $e");
      client.close();
    }
  }

  Future<void> _handleHttpRequest(
    Socket client,
    String requestStr,
    String firstLine,
    String ip,
  ) async {
    try {
      final method = firstLine.split(" ")[0];
      String rawUrl = firstLine.split(" ")[1];

      if (!rawUrl.startsWith("http")) {
        final host = _extractHeader(requestStr, "Host");
        rawUrl = "http://$host$rawUrl";
      }
      final uri = Uri.tryParse(rawUrl);

      if (uri == null) {
        client.close();
        return;
      }

      if (notifier.firewall.isBlocked(host: uri.host, url: uri.toString())) {
        client.write("HTTP/1.1 403 Forbidden\r\n");
        client.write("Content-Type: text/plain\r\n\r\n");
        client.write("Access Denied by ProxyApp Firewall\n");
        client.close();
        return;
      }


      tracker.updateLastDomain(ip, uri.host);

      final httpClient = HttpClient()
        ..connectionTimeout = Duration(seconds: 6)
        ..userAgent = "ProxyFlutter";

      final req = await httpClient.openUrl(method, uri);

      final res = await req.close();

      client.write("HTTP/1.1 ${res.statusCode} OK\r\n");
      res.headers.forEach((k, v) => client.write("$k: ${v.join(',')}\r\n"));
      client.write("\r\n");

      await for (final chunk in res) {
        tracker.addDownload(ip, chunk.length);
        client.add(chunk);
      }
    } catch (e) {
      debugPrint("Error HTTP: $e");
      notifier.addLog("❌ ERROR HTTP desde $ip → $e");
    }
  }

  String? _extractHeader(String request, String headerName) {
    final lines = request.split("\r\n");
    for (final line in lines) {
      if (line.toLowerCase().startsWith(headerName.toLowerCase())) {
        return line.split(": ").last.trim();
      }
    }
    return null;
  }

  Future<String?> _resolveMac(String ip) async {
    return null;
  }

  Future<String?> _resolveDeviceName(String ip) async {
    return null;
  }
}
