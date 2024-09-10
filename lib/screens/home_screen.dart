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
  int _ml = 220; // Initial amount in ml
  double _waveAmplitude = 10; // Initial wave amplitude

  void _increaseDrink() {
    setState(() {
      _ml += 50; // Increase by 50 ml
      _waveAmplitude += 5; // Increase wave amplitude
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
            tween: IntTween(
                begin: _ml - 50,
                end: _ml), // Animate from previous value to new value
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

          // Stack for the WaveWidget and BottomNavigationBarWidget
          Expanded(
            child: Stack(
              children: [
                // WaveWidget positioned at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    color: Colors.transparent, // Transparent background
                    height: double.parse(_ml.toString()),
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
                      size: Size(double.infinity,
                          double.parse(_ml.toString())), // Tinggi gelombang
                      waveAmplitude: _waveAmplitude, // Dynamic wave amplitude
                    ),
                  ),
                ),
                // BottomNavigationBar positioned at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBarWidget(),
                ),
                // Content area with ElevatedButton on top
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Atur tombol di bawah
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
                        SizedBox(
                            height:
                                100), // Spasi setelah tombol jika diperlukan
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
