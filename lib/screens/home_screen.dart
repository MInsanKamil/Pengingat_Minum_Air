import 'dart:math';
import 'dart:convert'; // Untuk encode/decode list ke string
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_shape_widget.dart';
import '../widgets/percent_indikator_widget.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

// undo, atur supaya ketika minum, sekalian atur volume air
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _ml = 0;
  int _waveHeight = 150;
  int _volume = 200;
  int _target = 2700;
  double _waveAmplitude = 10;

  @override
  void initState() {
    super.initState();
    _loadLatestDrinkLog(); // Memuat data minuman saat inisialisasi
  }

  void _increaseDrink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _ml += _volume;
      _waveHeight += (_volume / 10).round();
      _waveAmplitude += (_volume / 40).round();
    });

    // Mendapatkan waktu saat ini
    DateTime now = DateTime.now();
    // String formattedTime = "${now.hour}:${now.minute}";
    // String formattedDate = "${now.day}-${now.month}-${now.year}";

    // Simpan data ke dalam list
    List<String> drinkLog = prefs.getStringList('drinkLog') ?? [];
    String logEntry = jsonEncode({
      'volume': _volume,
      'time': now.toIso8601String(), // Store the date in ISO 8601 format
      'ml': _ml,
      'waveHeight': _waveHeight,
      'waveAmplitude': _waveAmplitude,
    });
    drinkLog.add(logEntry);

    // Simpan kembali ke SharedPreferences
    await prefs.setStringList('drinkLog', drinkLog);
  }

  void _loadLatestDrinkLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? drinkLog = prefs.getStringList('drinkLog');

    if (drinkLog != null && drinkLog.isNotEmpty) {
      // Dapatkan tanggal hari ini
      DateTime today = DateTime.now();
      String todayString =
          DateTime(today.year, today.month, today.day).toIso8601String();

      // Cari log terakhir yang sesuai dengan hari ini
      Map<String, dynamic>? latestTodayLog;

      for (String logEntry in drinkLog.reversed) {
        // Loop dari yang terbaru
        Map<String, dynamic> log = jsonDecode(logEntry);

        // Ambil tanggal dari log dan samakan dengan hari ini
        DateTime logDate = DateTime.parse(log['time']);
        String logDateString =
            DateTime(logDate.year, logDate.month, logDate.day)
                .toIso8601String();

        if (logDateString == todayString) {
          latestTodayLog = log;
          break;
        }
      }

      // Jika ditemukan log untuk hari ini, gunakan datanya
      if (latestTodayLog != null) {
        setState(() {
          _ml = latestTodayLog!['ml'];
          _volume = latestTodayLog['volume'];
          _waveHeight = latestTodayLog['waveHeight'];
          _waveAmplitude = latestTodayLog['waveAmplitude'];
        });
      } else {
        // Jika tidak ada log hari ini, set nilai ke 0
        setState(() {
          _ml = 0;
          _volume = 200;
          _waveHeight = 150;
          _waveAmplitude = 10;
        });
      }
    } else {
      // Jika log kosong, set nilai ke 0
      setState(() {
        _ml = 0;
        _volume = 200;
        _waveHeight = 150;
        _waveAmplitude = 10;
      });
    }
  }

  void _showVolumeDialog() async {
    int? newVolume = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempVolume = _volume;
        return AlertDialog(
          title: Text('Atur Volume Air'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Masukkan volume air (ml)"),
            onChanged: (value) {
              tempVolume = int.tryParse(value) ?? tempVolume;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                Navigator.of(context).pop(tempVolume);
              },
            ),
          ],
        );
      },
    );

    if (newVolume != null) {
      setState(() {
        _volume = newVolume;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: max(_ml - _volume, 0), end: _ml),
              duration: Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$value', // Angka "value"
                        style: TextStyle(
                          fontSize: size.width *
                              0.15, // Ukuran font berdasarkan lebar layar
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text: ' ml', // Satuan "ml"
                        style: TextStyle(
                          fontSize: size.width *
                              0.05, // Ukuran font lebih kecil berdasarkan lebar layar
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
                height: size.height * 0.01), // Jarak vertikal lebih responsif
            Text(
              'Target Harian: $_target ml',
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Pengingat Berikutnya: 06:00, Besok',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Tidak ada pengingat hari ini',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
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
                  Positioned(
                      bottom: size.height * 0.12, child: GlassShapeWidget()),
                  Positioned(
                    bottom: size.height * 0.22,
                    child: Text(
                      '$_volume ml',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.125,
                    child: ElevatedButton(
                      onPressed: _showVolumeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[500]!,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.03,
                          vertical: size.height * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Atur Volume Air',
                        style: TextStyle(
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
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
                                horizontal: size.width * 0.08,
                                vertical: size.height * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              '+ MINUM',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
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
                        SizedBox(height: size.height * 0.25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
