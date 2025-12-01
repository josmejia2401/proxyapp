import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxyapp/core/constants/app_colors.dart';
import 'package:proxyapp/features/proxy/controllers/proxy_notifier.dart';

class FirewallScreen extends StatefulWidget {
  @override
  State<FirewallScreen> createState() => _FirewallScreenState();
}

class _FirewallScreenState extends State<FirewallScreen> {
  final TextEditingController domainCtrl = TextEditingController();
  final TextEditingController keywordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();
    final fw = proxy.firewall;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text("Firewall"),
        centerTitle: true,
        elevation: 1,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Dominios bloqueados", Icons.shield_moon_rounded),

          _card(
            child: Column(
              children: [
                if (fw.blockedDomains.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No hay dominios bloqueados",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ),

                ...fw.blockedDomains.map(
                  (d) => _ruleTile(
                    icon: Icons.block_rounded,
                    color: Colors.redAccent,
                    text: d,
                    onDelete: () => proxy.removeBlockedDomain(d),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _inputCard(
            controller: domainCtrl,
            label: "Agregar dominio",
            hint: "facebook.com",
            onAdd: () {
              final v = domainCtrl.text.trim();
              if (v.isEmpty) return;
              proxy.addBlockedDomain(v);
              domainCtrl.clear();
            },
          ),

          const SizedBox(height: 30),

          _sectionTitle("Keywords bloqueados", Icons.filter_alt_off_rounded),

          _card(
            child: Column(
              children: [
                if (fw.blockedKeywords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No hay keywords bloqueadas",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ),

                ...fw.blockedKeywords.map(
                  (k) => _ruleTile(
                    icon: Icons.no_sim_rounded,
                    color: Colors.orange,
                    text: k,
                    onDelete: () => proxy.removeKeyword(k),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _inputCard(
            controller: keywordCtrl,
            label: "Agregar keyword",
            hint: "ads, tracker, analytics...",
            onAdd: () {
              final v = keywordCtrl.text.trim();
              if (v.isEmpty) return;
              proxy.addKeyword(v);
              keywordCtrl.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _ruleTile({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_forever_rounded,
          color: Colors.redAccent.shade200,
        ),
        onPressed: onDelete,
      ),
    );
  }

  Widget _inputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label, hintText: hint),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Añadir"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
