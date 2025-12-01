import 'dart:async';
import 'package:proxyapp/features/proxy/controllers/cache_service.dart';

class FirewallService {
  /// Dominios exactos como: "facebook.com"
  final Set<String> blockedDomains = {};

  /// Palabras clave (ads, tracker…)
  final Set<String> blockedKeywords = {};

  /// Patrones avanzados (regex)
  final List<RegExp> blockedPatterns = [];

  final StreamController<void> _stream = StreamController.broadcast();
  Stream<void> get stream => _stream.stream;

  FirewallService() {
    _loadDefaultRules();
    loadRules();
  }

  bool isBlocked({required String host, required String url}) {
    final h = host.toLowerCase();
    final u = url.toLowerCase();

    // 1. Dominio exacto
    if (blockedDomains.contains(h)) return true;

    // 2. Keyword simple
    for (final k in blockedKeywords) {
      if (h.contains(k) || u.contains(k)) return true;
    }

    // 3. Pattern avanzado
    for (final p in blockedPatterns) {
      if (p.hasMatch(h) || p.hasMatch(u)) return true;
    }

    return false;
  }

  void addDomain(String domain) {
    blockedDomains.add(domain.toLowerCase());
    saveRules();
    _stream.add(null);
  }

  void removeDomain(String domain) {
    blockedDomains.remove(domain.toLowerCase());
    saveRules();
    _stream.add(null);
  }

  void addKeyword(String key) {
    blockedKeywords.add(key.toLowerCase());
    saveRules();
    _stream.add(null);
  }

  void removeKeyword(String key) {
    blockedKeywords.remove(key.toLowerCase());
    saveRules();
    _stream.add(null);
  }

  void _loadDefaultRules() {
    blockedDomains.addAll({
      "doubleclick.net",
      "googlesyndication.com",
      "googleadservices.com",
      "ads.youtube.com",
      "adservice.google.com",
      "adservice.google.com.co",
      "admob.com",
      "moatads.com",
      "taboola.com",
      "outbrain.com",
      "spotxchange.com",
      "zedo.com",
      "adform.net",
      "adnxs.com",
      "amazon-adsystem.com",
      "criteo.com",
      "criteo.net",
      "trustx.org",
      "rubiconproject.com",
    });

    // ================================
    // PALABRAS CLAVE
    // ================================
    blockedKeywords.addAll({
      "ads",
      "adservice",
      "doubleclick",
      "tracking",
      "analytics",
      "beacon",
      "pixel",
      "metrics",
      "banner",
      "sponsor",
    });

    blockedPatterns.addAll([
      RegExp(r"ads?[0-9]*\."), // ads1., ads2., ad., ad4.
      RegExp(r"tracking\."), // tracking.domain
      RegExp(r"(.*)\.doubleclick\.net$"), // cualquier subdominio de doubleclick
      RegExp(r"(.*)\.googlesyndication\.com$"),
    ]);
  }

  Future<void> loadRules() async {
    final cache = CacheService.instance;
    final domains = cache.readList("fw_domains");
    final keywords = cache.readList("fw_keywords");

    if (domains != null) {
      blockedDomains.addAll(domains.map((e) => e.toString()));
    }
    if (keywords != null) {
      blockedKeywords.addAll(keywords.map((e) => e.toString()));
    }
  }

  Future<void> saveRules() async {
    final cache = CacheService.instance;
    await cache.writeList("fw_domains", blockedDomains.toList());
    await cache.writeList("fw_keywords", blockedKeywords.toList());
  }
}
