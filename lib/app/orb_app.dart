import 'package:flutter/material.dart';

/// The root widget of the app.
///
/// For now it shows an empty screen. The theme (PMG6-46) and the go_router
/// tab shell (PMG6-47) plug in here.
class OrbApp extends StatelessWidget {
  const OrbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Orb',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SizedBox.expand()),
    );
  }
}
