import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _ml = 0;
  int _waveHeight = 150;
  int _target = 1220;
  double _waveAmplitude = 10;

  void _increaseDrink() {
    setState(() {
      _ml += 50;
      _waveHeight += 50;
      _waveAmplitude += 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 100),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: _ml - 50, end: _ml),
            duration: Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Text(
                '$value ml',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
          ),
          SizedBox(height: 10),
          Text(
            'Target Harian: $_target ml',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Pengingat Berikutnya: 06:00, Besok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Tidak ada pengingat hari ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 50),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    color: Colors.transparent,
                    height: double.parse(_waveHeight.toString()),
                    child: WaveWidget(
                      config: CustomConfig(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.7),
                        ],
                        durations: [3000, 6000, 12000], // Variasi durasi
                        heightPercentages: [
                          0.15,
                          0.20,
                          0.25
                        ], // Variasi ketinggian
                        blur: MaskFilter.blur(BlurStyle.solid, 10),
                      ),
                      size: Size(
                          double.infinity,
                          double.parse(
                              _waveHeight.toString())), // Tinggi gelombang
                      waveAmplitude: _waveAmplitude,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBarWidget(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _increaseDrink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            '+ MINUM',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
