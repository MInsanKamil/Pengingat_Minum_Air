import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/glass_shape_widget.dart';
import '../widgets/percent_indikator_widget.dart';
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
  int _volume = 200;
  int _target = 1220;
  double _waveAmplitude = 10;

  void _increaseDrink() {
    setState(() {
      _ml += _volume;
      _waveHeight += 30;
      _waveAmplitude += 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        children: [
          SizedBox(height: 50),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: _ml - 50, end: _ml),
            duration: Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$value', // Angka "value"
                      style: TextStyle(
                        fontSize: 70, // Ukuran font untuk value
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    TextSpan(
                      text: ' ml', // Satuan "ml"
                      style: TextStyle(
                          fontSize: 24, // Ukuran font lebih kecil untuk "ml"
                          fontWeight: FontWeight.normal,
                          color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 10),
          Text(
            'Target Harian: $_target ml',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Pengingat Berikutnya: 06:00, Besok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Tidak ada pengingat hari ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          // Custom Paint Glass Shape with wave inside

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
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.5),
                        ],
                        durations: [3000, 6000, 12000],
                        heightPercentages: [0.15, 0.20, 0.25],
                        blur: MaskFilter.blur(BlurStyle.solid, 10),
                      ),
                      size: Size(double.infinity,
                          double.parse(_waveHeight.toString())),
                      waveAmplitude: _waveAmplitude,
                    ),
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: BottomNavigationBarWidget(),
                // ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlassShapeWidget(
                        volume: _volume,
                      ),
                    ],
                  ),
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
                            backgroundColor: Colors.lightBlue[500]!,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            '+ MINUM',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PercentIndicator(
                          percentage: min((_ml / _target) * 100, 100)),
                      SizedBox(height: 150),
                    ],
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
