import 'package:flutter/material.dart';
import 'package:proxyapp/features/home/presentation/tab_navigator.dart';
import 'package:proxyapp/features/home/presentation/tabs/config_tab.dart';
import 'package:proxyapp/features/home/presentation/tabs/dashboard_tab.dart';
import 'package:proxyapp/features/home/presentation/tabs/device_tab.dart';
import 'package:proxyapp/core/constants/app_colors.dart';
import 'package:proxyapp/features/home/presentation/tabs/logs_tab.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // Claves únicas para cada Navigator de tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Dashboard
    GlobalKey<NavigatorState>(), // Dispositivos
    GlobalKey<NavigatorState>(), // Config
    GlobalKey<NavigatorState>(), // Logs
  ];

  void _selectTab(int index) {
    if (_currentIndex == index) {
      // Si el usuario toca la tab actual, se reinicia el stack a la raíz
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Las pantallas principales para cada tab
  final List<Widget> _tabs = const [
    DashboardTab(),
    DeviceTab(),
    ConfigTab(),
    LogsTab()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          return Offstage(
            offstage: _currentIndex != index,
            child: TabNavigator(
              navigatorKey: _navigatorKeys[index],
              child: tab,
            ),
          );
        }).toList(),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Dispositivos',
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Logs',
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}