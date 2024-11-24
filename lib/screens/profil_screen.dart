import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalMinum = 0;
  int totalMinumToday = 0;
  int totalHariTercapai = 0;
  int targetHarian = 0;
  String jenisKelamin = '';
  int umur = 0;
  List<Map<String, dynamic>> _drinkLogs = [];
  DateTime? _lastAchievementDate;

  // Reminder settings
  int selangWaktu = 30;
  TimeOfDay waktuTidur = TimeOfDay(hour: 23, minute: 0);
  TimeOfDay waktuBangun = TimeOfDay(hour: 8, minute: 0);
  bool isStopReminder = false;
  bool isManualTargetEnabled = false;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int calculateTargetHarian() {
    if (umur >= 1 && umur <= 2) return 1200;
    if (umur == 3) return 1300;
    if (umur >= 4 && umur <= 8) return 1600;
    if (umur >= 9 && umur <= 13) {
      return jenisKelamin == 'Laki-laki' ? 2100 : 1900;
    }
    if (umur >= 14 && umur <= 18) {
      return jenisKelamin == 'Laki-laki' ? 2500 : 2000;
    }
    if (umur >= 19) {
      return jenisKelamin == 'Laki-laki' ? 2500 : 2000;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    if (!isManualTargetEnabled) targetHarian = calculateTargetHarian();
    _loadPreferences();
    _loadTotalMinum();
    _loadTotalTercapai(); // Memuat data minuman saat inisialisasi
  }

  Future<void> _loadTotalTercapai() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalHariTercapai = prefs.getInt('totalTercapai') ?? totalHariTercapai;
    });
  }

  Future<void> _updateTotalTercapai() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? drinkLog = prefs.getStringList('drinkLog');
      print(drinkLog);
      String? lastAchievementDateStr = prefs.getString('lastAchievementDate');
      if (drinkLog != null) {
        if (lastAchievementDateStr != null) {
          _lastAchievementDate = DateTime.parse(lastAchievementDateStr);
        } else {
          _lastAchievementDate =
              null; // Pastikan untuk menginisialisasi dengan null
        }

        _drinkLogs = drinkLog
            .map((log) => jsonDecode(log) as Map<String, dynamic>)
            .where((log) {
          DateTime logDate = DateTime.parse(log['time']);
          return logDate.year == DateTime.now().year &&
              logDate.month == DateTime.now().month &&
              logDate.day == DateTime.now().day;
        }).toList();

        totalMinumToday =
            _drinkLogs.isNotEmpty ? (_drinkLogs.last['ml'] ?? 0) : 0;

        if (totalMinumToday < targetHarian &&
            (_lastAchievementDate != null ||
                _isSameDay(_lastAchievementDate!, DateTime.now()))) {
          await prefs.remove('lastAchievementDate');
          totalHariTercapai = prefs.getInt('totalTercapai') ?? 0;
          if (totalHariTercapai > 0) {
            totalHariTercapai--;
            await prefs.setInt(
                'totalTercapai', totalHariTercapai); // Update totalTercapai
          }
        }

        if (totalMinumToday >= targetHarian &&
            (_lastAchievementDate == null ||
                !_isSameDay(_lastAchievementDate!, DateTime.now()))) {
          totalHariTercapai = prefs.getInt('totalTercapai') ?? 0;
          totalHariTercapai++;
          _lastAchievementDate = DateTime.now();

          // Simpan total pencapaian dan tanggal terakhir tercapai ke SharedPreferences
          await prefs.setInt('totalTercapai', totalHariTercapai);
          await prefs.setString(
              'lastAchievementDate', _lastAchievementDate!.toIso8601String());
        }

        setState(() {
          totalHariTercapai =
              prefs.getInt('totalTercapai') ?? totalHariTercapai;
        });
      } else {
        return;
      }
    } catch (e) {
      // Menampilkan error pada konsol untuk debugging
      print("Error saat memperbarui total tercapai: $e");
      // Opsional: Menampilkan pesan error kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui total tercapai")),
      );
    }
  }

  Future<void> _loadPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        targetHarian = prefs.getInt('targetHarian') ?? targetHarian;
        jenisKelamin = prefs.getString('jenisKelamin') ?? jenisKelamin;
        umur = prefs.getInt('umur') ?? umur;
        isManualTargetEnabled =
            prefs.getBool('isManual') ?? isManualTargetEnabled;
      });
    } catch (e) {
      // Menampilkan error pada konsol untuk debugging
      print("Error saat memuat preferensi: $e");
      // Opsional: Menampilkan pesan error kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat preferensi")),
      );
    }
  }

  Future<void> _loadTotalMinum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? drinkLog = prefs.getStringList('drinkLog');
    setState(() {
      _drinkLogs = drinkLog!
          .map((log) => jsonDecode(log) as Map<String, dynamic>)
          .toList();

// Update _ml dengan jumlah total minuman dalam semua log
      totalMinum =
          _drinkLogs.fold(0, (sum, log) => sum + (log['volume'] as int));
    });
  }

  Future<void> _savePreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('targetHarian', targetHarian);
      await prefs.setString('jenisKelamin', jenisKelamin);
      await prefs.setInt('umur', umur);
      await prefs.setBool('isManual', isManualTargetEnabled);
    } catch (e) {
      // Menampilkan error pada konsol untuk debugging
      print("Error saat menyimpan preferensi: $e");
      // Opsional: Menampilkan pesan error kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan preferensi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Bagian profil atas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.0,
                      color: Colors.blue[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Sinkronkan Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),

              // Bagian Total Minum dan Total Tercapai
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.water_drop_outlined, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            '$totalMinum ml',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'Total minum',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[500],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            '$totalHariTercapai Hari',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'Total tercapai',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Atur Manual Target Minum Harian',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: isManualTargetEnabled,
                    onChanged: (value) {
                      setState(() async {
                        isManualTargetEnabled = value;
                        if (!isManualTargetEnabled) {
                          // Update target harian secara otomatis jika switch mati
                          targetHarian = calculateTargetHarian();
                        }
                        await _savePreferences();
                        await _loadPreferences();
                        await _updateTotalTercapai();
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.blue[500],
                    inactiveThumbColor: Colors.blue[300],
                    inactiveTrackColor: Colors.white,
                    trackOutlineColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ],
              ),

              // Pengaturan lainnya
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingTile(Icons.notifications, 'Pengingat',
                        onTap: () {
                      _showReminderSettings();
                    }),
                    SizedBox(height: 10),
                    _buildSettingTile(
                      Icons.water_drop,
                      'Target harian',
                      subtitle: '$targetHarian ml',
                      onTap: isManualTargetEnabled
                          ? () => _showEditDialog(
                                  context, 'Target Harian', '$targetHarian',
                                  (value) {
                                // Update tujuan harian
                                setState(() {
                                  targetHarian =
                                      int.tryParse(value) ?? targetHarian;
                                });
                              })
                          : () {}, // Fungsi kosong saat switch mati
                    ),
                    SizedBox(height: 10),
                    _buildSettingTile(
                      Icons.person,
                      'Jenis kelamin',
                      subtitle: '$jenisKelamin',
                      onTap: () => _showGenderSelectionModal(
                          context, jenisKelamin, (value) {
                        // Update jenis kelamin
                        setState(() {
                          jenisKelamin = value;
                          targetHarian = calculateTargetHarian();
                        });
                      }),
                    ),
                    SizedBox(height: 10),
                    _buildSettingTile(
                      Icons.calendar_today,
                      'Umur',
                      subtitle: '$umur tahun',
                      onTap: () =>
                          _showEditDialog(context, 'Umur', '$umur', (value) {
                        // Update umur
                        setState(() {
                          umur = int.tryParse(value) ?? umur;
                          targetHarian = calculateTargetHarian();
                        });
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title,
      {String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.white70))
          : null,
      trailing: title == 'Target harian' && !isManualTargetEnabled
          ? null // Trailing hilang jika Target harian dan isManualTargetEnabled == false
          : Icon(Icons.arrow_forward_ios,
              color: Colors
                  .white), // Menampilkan trailing yang diberikan kecuali untuk Target harian
      contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      tileColor: Colors.blue[500],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      onTap: onTap,
    );
  }

  void _showGenderSelectionModal(
      BuildContext context, String currentValue, Function(String) onUpdate) {
    final List<String> genderOptions = ['Laki-laki', 'Perempuan'];
    String selectedValue = currentValue;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pilih Jenis Kelamin',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[500]),
              ),
            ),
            Divider(),
            Column(
              children: genderOptions.map((String value) {
                return RadioListTile<String>(
                  title: Text(value, style: TextStyle(color: Colors.blue[500])),
                  value: value,
                  groupValue: selectedValue,
                  activeColor: Colors.blue[500],
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // Tidak dapat ditutup saat loading
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text("Menyimpan...",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[500])),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      setState(() {
                        selectedValue = newValue;
                        onUpdate(newValue); // Update the selected value
                      });

                      await _savePreferences();
                      await _loadPreferences();
                      await _updateTotalTercapai();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Close the modal
                    }
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue,
      Function(String) onUpdate) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Mengatur agar tidak tertutup keyboard
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.blue[500],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Masukkan $title",
                    hintStyle: TextStyle(color: Colors.blue[500]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue[500]!), // Custom color
                    ),
                    // Customize the underline when the field is focused
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue[700]!,
                          width: 2.0), // Custom color and width
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Tidak dapat ditutup saat loading
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Menyimpan...",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[500])),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        onUpdate(controller.text);
                        await _savePreferences();
                        await _loadPreferences();
                        await _updateTotalTercapai();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Simpan',
                          style: TextStyle(color: Colors.blue[500])),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Batal',
                          style: TextStyle(color: Colors.blue[500])),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReminderSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal menyesuaikan konten
      backgroundColor: Colors.white70, // Transparan di luar modal
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              padding: EdgeInsets.all(20.0),
              child: Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pengaturan Pengingat',
                          style: TextStyle(
                              color: Colors.blue[500],
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Selang Waktu',
                          style:
                              TextStyle(color: Colors.blue[500], fontSize: 16)),
                      Container(
                        margin: EdgeInsets.only(left: 18, top: 7),
                        padding:
                            EdgeInsets.only(left: 10, right: 10), // Margin kiri
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blue[500]!,
                              width:
                                  2), // Ganti warna dan lebar sesuai kebutuhan
                          borderRadius:
                              BorderRadius.circular(10), // Radius border
                        ),
                        child: DropdownButton<int>(
                          value: selangWaktu,
                          borderRadius: BorderRadius.circular(10),
                          underline:
                              SizedBox(), // Hilangkan garis bawah default
                          dropdownColor: Colors.white,
                          onChanged: (int? newValue) {
                            setStateModal(() {
                              selangWaktu = newValue!;
                            });
                          },
                          items: <int>[30, 60, 120] // nilai dalam menit
                              .asMap()
                              .entries
                              .map<DropdownMenuItem<int>>((entry) {
                            int index = entry.key;
                            int value = entry.value;
                            String label;

                            if (value == 60) {
                              label =
                                  '1 jam'; // Tampilkan '1 jam' saat value 60
                            } else if (value == 120) {
                              label =
                                  '2 jam'; // Tampilkan '2 jam' saat value 120
                            } else {
                              label =
                                  '$value menit'; // Tampilkan dalam menit untuk opsi lainnya
                            }

                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                label,
                                style: TextStyle(color: Colors.blue[500]),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Waktu Tidur',
                          style:
                              TextStyle(color: Colors.blue[500], fontSize: 16)),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blue[500]!,
                              width:
                                  2), // Ganti warna dan lebar sesuai kebutuhan
                          borderRadius:
                              BorderRadius.circular(10), // Radius border
                        ),
                        child: ListTile(
                          title: Text('Dari: ${waktuTidur.format(context)}',
                              style: TextStyle(color: Colors.blue[500])),
                          trailing: Icon(Icons.edit, color: Colors.blue[500]),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: waktuTidur,
                            );
                            if (picked != null && picked != waktuTidur) {
                              setStateModal(() {
                                waktuTidur = picked;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blue[500]!,
                              width:
                                  2), // Ganti warna dan lebar sesuai kebutuhan
                          borderRadius:
                              BorderRadius.circular(10), // Radius border
                        ),
                        child: ListTile(
                          title: Text('Hingga: ${waktuBangun.format(context)}',
                              style: TextStyle(color: Colors.blue[500])),
                          trailing: Icon(Icons.edit, color: Colors.blue[500]),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: waktuBangun,
                            );
                            if (picked != null && picked != waktuBangun) {
                              setStateModal(() {
                                waktuBangun = picked;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text('Hentikan ketika target tercapai',
                                  style: TextStyle(
                                      color: Colors.blue[500],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                          Switch(
                            value: isStopReminder,
                            activeColor: Colors.blue[300],
                            activeTrackColor: Colors.blue[700],
                            inactiveThumbColor: Colors.blue[300],
                            inactiveTrackColor: Colors.white70,
                            trackOutlineColor:
                                MaterialStateProperty.all(Colors.blue),
                            onChanged: (value) {
                              setStateModal(() {
                                isStopReminder = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Simpan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
