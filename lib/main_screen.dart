import 'package:ezmoney/home_screen.dart';
import 'package:ezmoney/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ZoomDrawerController drawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: drawerController,
      menuScreen: const MenuScreen(),
      mainScreen: const HomeScreen(),
      borderRadius: 30.0,
      showShadow: true,
      angle: 0.0,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      menuBackgroundColor: const Color(0xFF4A7FFF),
      mainScreenScale: 0.2,
    );
  }
}
