import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CachedDnsEntry {
  final String ip;
  final DateTime expiry;

  CachedDnsEntry(this.ip, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class DnsResolver {
  static final DnsResolver instance = DnsResolver._internal();
  DnsResolver._internal();

  final Map<String, CachedDnsEntry> _cache = {};
  final int maxCacheSize = 2000;

  /// DNS públicos
  final List<String> dnsProviders = [
    "https://cloudflare-dns.com/dns-query", // 1.1.1.1
    "https://dns.google/resolve", // 8.8.8.8
    "https://dns.quad9.net/dns-query", // 9.9.9.9
  ];

  Future<String?> resolve(String domain) async {
    if (domain.isEmpty) return null;

    domain = domain.trim().toLowerCase();

    final cached = _cache[domain];
    if (cached != null && !cached.isExpired) {
      return cached.ip;
    }

    final ip = await _resolveViaHttpsDns(domain);

    if (ip != null) {
      _saveToCache(domain, ip, ttlSeconds: 300); // TTL 5 min
      return ip;
    }

    return domain;
  }

  Future<String?> _resolveViaHttpsDns(String domain) async {
    for (final endpoint in dnsProviders) {
      try {
        final url = Uri.parse("$endpoint?name=$domain&type=A");

        final res = await http
            .get(url, headers: {"Accept": "application/dns-json"})
            .timeout(const Duration(seconds: 3));

        if (res.statusCode != 200) continue;

        final json = jsonDecode(res.body);

        if (json["Answer"] != null) {
          for (final ans in json["Answer"]) {
            if (ans["type"] == 1) {
              // type 1 = A record
              return ans["data"];
            }
          }
        }
      } catch (_) {
        // Ignorar y seguir con siguiente proveedor
      }
    }
    return null;
  }

  void _saveToCache(String domain, String ip, {required int ttlSeconds}) {
    if (_cache.length >= maxCacheSize) {
      // remover el primero (LRU simple)
      _cache.remove(_cache.keys.first);
    }

    final expiry = DateTime.now().add(Duration(seconds: ttlSeconds));
    _cache[domain] = CachedDnsEntry(ip, expiry);
  }

  void clear() => _cache.clear();
}
