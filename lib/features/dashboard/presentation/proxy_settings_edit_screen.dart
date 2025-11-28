import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../proxy/controllers/proxy_notifier.dart';

class ProxySettingsEditScreen extends StatefulWidget {
  @override
  State<ProxySettingsEditScreen> createState() =>
      _ProxySettingsEditScreenState();
}

class _ProxySettingsEditScreenState extends State<ProxySettingsEditScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final proxy = context.read<ProxyNotifier>();
    controller = TextEditingController(text: proxy.port.toString());
  }

  @override
  Widget build(BuildContext context) {
    final proxy = context.watch<ProxyNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar Puerto"),
        centerTitle: true,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _inputCard(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Puerto del Proxy",
                  hintText: "Ej: 8080",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Guardar Cambios"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final p = int.tryParse(controller.text);
                  if (p != null) {
                    await proxy.setPort(p);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: child,
    );
  }
}
