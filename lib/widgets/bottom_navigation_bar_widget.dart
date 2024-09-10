import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.water_drop),
          label: 'Hari ini',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.insights),
        //   label: 'Wawasan',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Saya',
        ),
      ],
    );
  }
}
