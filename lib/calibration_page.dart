import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CalibrationPage extends StatefulWidget {
  final String deviceName; // 👈 รับชื่อบอร์ด

  const CalibrationPage({super.key, required this.deviceName});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  late DatabaseReference ref; // 👈 ไม่ fix path ตรงนี้แล้ว

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // 👇 ใช้ deviceName ที่ส่งเข้ามา
    ref = FirebaseDatabase.instance
        .ref("${widget.deviceName}/calibration/request");
  }

  Future<void> sendCalibrationRequest() async {
    setState(() => isLoading = true);

    await ref.set(true);

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Calibration requested for ${widget.deviceName} ✅"),
        backgroundColor: const Color(0xFF6E9F8D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Calibration - ${widget.deviceName}", // 👈 แสดงชื่อบอร์ด
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF6E9F8D).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_seat,
                    size: 60,
                    color: Color(0xFF6E9F8D),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Set Correct Sitting Posture",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Sit in your correct posture position.\nPress the button below to calibrate the system.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : sendCalibrationRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF6E9F8D),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Start Calibration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}