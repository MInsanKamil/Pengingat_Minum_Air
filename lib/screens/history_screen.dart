import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this to your pubspec.yaml
import '../widgets/intake_record_box_widget.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedTab = 'HARI'; // Track selected tab
  DateTime _currentDate =
      DateTime.now().add(Duration(minutes: 5)); // Track selected day
  DateTime _today = DateTime.now(); // To compare with today's date

  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _nextDay() {
    setState(() {
      // Prevent navigating to a future date
      if (_currentDate.isBefore(_today)) {
        _currentDate = _currentDate.add(Duration(days: 1));
      }
    });
  }

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
    });
  }

  String _getDisplayDate() {
    // Show "Hari Ini" if it's today's date
    if (_currentDate.year == _today.year &&
        _currentDate.month == _today.month &&
        _currentDate.day == _today.day) {
      return "Hari Ini";
    } else {
      return "${_currentDate.day}-${_currentDate.month}-${_currentDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blue[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _onTabSelected('HARI'),
              child: Column(
                children: [
                  Text(
                    'HARI',
                    style: TextStyle(
                      color: _selectedTab == 'HARI'
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (_selectedTab == 'HARI')
                    Container(
                      height: 2,
                      width: 40,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _onTabSelected('MINGGU'),
              child: Column(
                children: [
                  Text(
                    'MINGGU',
                    style: TextStyle(
                      color: _selectedTab == 'MINGGU'
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (_selectedTab == 'MINGGU')
                    Container(
                      height: 2,
                      width: 40,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _onTabSelected('BULAN'),
              child: Column(
                children: [
                  Text(
                    'BULAN',
                    style: TextStyle(
                      color: _selectedTab == 'BULAN'
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (_selectedTab == 'BULAN')
                    Container(
                      height: 2,
                      width: 40,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Navigation buttons for date history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _previousDay,
                ),
                Text(
                  _getDisplayDate(),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: _currentDate.isBefore(_today)
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                  onPressed: _currentDate.isBefore(_today) ? _nextDay : null,
                ),
              ],
            ),
            SizedBox(height: 5),

            // Graph Section
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.only(bottom: 10, left: 10, right: 20, top: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[500],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tambahkan teks di atas LineChart
                    Row(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(), // Untuk memisahkan kedua teks
                        Text(
                          'Target',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '2000 ml',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(), // Untuk memisahkan kedua teks
                        Text(
                          '1220 ml',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                        height: 20), // Beri jarak antara teks dan LineChart
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval:
                                500, // Adjust this based on your needs
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors
                                    .white54, // Set the color of the horizontal lines
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), // Disable top titles
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), // Disable right titles
                            ),
                            leftTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Volume Air (ml)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              sideTitles: SideTitles(
                                reservedSize: 60,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 1000) {
                                    return Text(
                                      '    ' + value.toInt().toString(),
                                      style: TextStyle(color: Colors.white),
                                    );
                                  } else {
                                    return Text(
                                      '    ' + value.toInt().toString(),
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Waktu (Jam)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              sideTitles: SideTitles(
                                reservedSize: 25,
                                showTitles: true,
                                interval: 4, // Show labels at intervals of 4
                                getTitlesWidget: (value, meta) {
                                  if (value % 4 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(color: Colors.white),
                                    );
                                  } else {
                                    return Container(); // Hide other titles
                                  }
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(5, 500),
                                FlSpot(6.50, 700),
                                FlSpot(8.59, 1100),
                                FlSpot(12, 1800),
                                FlSpot(15, 2000),
                              ],
                              isCurved: true,
                              color: Colors.white,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.5),
                                    Colors.blue.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: 1220, // Nilai pada sumbu Y
                                color: Colors.lightBlueAccent, // Warna garis
                                strokeWidth: 2,
                                dashArray: [
                                  5,
                                  5
                                ], // Menjadikan garis putus-putus
                                label: HorizontalLineLabel(
                                  show: true,
                                  labelResolver: (line) => '1220 ml',
                                  alignment: Alignment.topRight,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          minX: 0, // Set min X-axis value
                          maxX: 24, // Set max X-axis value
                          maxY: 3000,
                          minY: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 5),
            // Water intake history (Catatan) section
            Container(
              height: screenHeight / 4,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[500],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Theme(
                      data: ThemeData(highlightColor: Colors.white70),
                      child: Scrollbar(
                        thumbVisibility: true,
                        radius:
                            Radius.circular(10), // Ujung scrollbar yang rounded
                        scrollbarOrientation:
                            ScrollbarOrientation.right, // Posisi scrollbar
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              IntakeRecord(intake: '500 ml', time: '05:00'),
                              SizedBox(height: 10),
                              IntakeRecord(intake: '200 ml', time: '06:50'),
                              SizedBox(height: 10),
                              IntakeRecord(intake: '400 ml', time: '08:59'),
                              SizedBox(height: 10),
                              IntakeRecord(intake: '700 ml', time: '12:00'),
                              SizedBox(height: 10),
                              IntakeRecord(
                                  intake: '200 ml',
                                  time: '15:00'), // Example of more records
                            ],
                          ),
                        ),
                      ),
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

void main() => runApp(MaterialApp(
      home: HistoryScreen(),
    ));
