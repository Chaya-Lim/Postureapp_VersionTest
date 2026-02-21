import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  final String deviceName; // 👈 เพิ่มตัวนี้

  const HistoryPage({super.key, required this.deviceName});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late DatabaseReference ref; // 👈 เปลี่ยนจาก final เป็น late

  Map<String, Map<String, dynamic>> dailyData = {};
  List<String> sortedDates = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();

    // 👇 ใช้ deviceName ที่ส่งเข้ามา
    ref = FirebaseDatabase.instance
        .ref("${widget.deviceName}/history");

    loadHistory();
  }

  void loadHistory() {
    ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      Map historyData = data as Map;
      Map<String, Map<String, dynamic>> tempDaily = {};

      historyData.forEach((date, dateValue) {
        int correct = 0;
        int incorrect = 0;

        Map times = dateValue as Map;

        times.forEach((time, value) {
          if (value["posture"] == "correct") {
            correct++;
          } else {
            incorrect++;
          }
        });

        int total = correct + incorrect;
        double percent = total == 0 ? 0 : (correct / total) * 100;

        tempDaily[date] = {
          "correct": correct,
          "incorrect": incorrect,
          "percent": percent,
        };
      });

      List<String> dates = tempDaily.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      setState(() {
        dailyData = tempDaily;
        sortedDates = dates;
        selectedDate = dates.isNotEmpty ? dates.first : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sortedDates.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = dailyData[selectedDate]!;

    double correct = data["correct"].toDouble();
    double incorrect = data["incorrect"].toDouble();
    double percent = data["percent"];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "History (${widget.deviceName})", // 👈 แสดงชื่อบอร์ดได้ด้วย
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ===== DATE SELECTOR CARD =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: DropdownButton<String>(
                value: selectedDate,
                isExpanded: true,
                underline: const SizedBox(),
                items: sortedDates.map((date) {
                  return DropdownMenuItem(
                    value: date,
                    child: Text(date),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDate = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            // ===== CHART CARD =====
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Posture Success Rate",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: [
                              PieChartSectionData(
                                value: correct,
                                color: const Color(0xFF6E9F8D),
                                radius: 50,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: incorrect,
                                color: Colors.redAccent,
                                radius: 50,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${percent.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: percent >= 70
                                    ? const Color(0xFF6E9F8D)
                                    : percent >= 40
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                            const Text("Correct"),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      _buildLegend(
                          const Color(0xFF6E9F8D),
                          "Correct: ${correct.toInt()}"),
                      const SizedBox(width: 20),
                      _buildLegend(
                          Colors.redAccent,
                          "Incorrect: ${incorrect.toInt()}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== SUGGESTION CARD =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6E9F8D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getSuggestion(percent),
                style: const TextStyle(
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  String _getSuggestion(double percent) {
    if (percent >= 80) {
      return "Excellent posture 👏 \nท่านั่งดีมาก หลังตรงสม่ำเสมอ รักษาพฤติกรรมนี้ไว้";
    } else if (percent >= 60) {
      return "Good but can improve \nโดยรวมดี แต่ยังมีบางช่วงที่นั่งผิด ควรระวังการเอนตัว";
    } else if (percent >= 40) {
      return "Needs improvement \nมีการนั่งผิดค่อนข้างบ่อย ควรปรับท่านั่งให้ตรงมากขึ้น";
    } else {
      return "Posture needs serious attention \nท่านั่งส่วนใหญ่ผิด เสี่ยงปวดหลัง ควรปรับทันที";
    }
  }
}