import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  final String deviceName;

  const HistoryPage({super.key, required this.deviceName});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late DatabaseReference ref;

  Map<String, Map<String, dynamic>> dailyData = {};
  List<String> sortedDates = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref("${widget.deviceName}/history");
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
        int unknown = 0;

        Map<String, int> detailCount = {};
        Map times = dateValue as Map;

        times.forEach((time, value) {
          String posture = value["posture"] ?? "unknown";

          if (posture == "correct") {
            correct++;
          } else if (posture == "incorrect") {
            incorrect++;

            if (value["postureDetail"] != null) {
              String detail = value["postureDetail"];
              List<String> parts = detail.split(",");

              for (var p in parts) {
                String trimmed = p.trim();
                if (trimmed.isEmpty) continue;
                detailCount[trimmed] =
                    (detailCount[trimmed] ?? 0) + 1;
              }
            }
          } else {
            // unknown
            unknown++;
          }
        });

        int totalValid = correct + incorrect;
        double percent =
            totalValid == 0 ? 0 : (correct / totalValid) * 100;

        tempDaily[date] = {
          "correct": correct,
          "incorrect": incorrect,
          "unknown": unknown,
          "percent": percent,
          "detailCount": detailCount,
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
    if (sortedDates.isEmpty || selectedDate == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = dailyData[selectedDate]!;

    double correct = data["correct"].toDouble();
    double incorrect = data["incorrect"].toDouble();
    double unknown = data["unknown"].toDouble();
    double percent = data["percent"];
    Map<String, int> detailCount =
        Map<String, int>.from(data["detailCount"]);

    bool noValidData = (correct + incorrect) == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "History (${widget.deviceName})",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // DATE SELECTOR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
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

            // PIE CHART CARD
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                    child: noValidData
                        ? const Center(
                            child: Text(
                              "ยังไม่มีข้อมูลการนั่ง\n(ยังไม่ได้ปรับเทียบ)",
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Stack(
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

                  const SizedBox(height: 15),

                  if (!noValidData)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6E9F8D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Correct: ${correct.toInt()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(width: 25),

                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Incorrect: ${incorrect.toInt()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6E9F8D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _buildSummary(percent, correct.toInt(),
                    incorrect.toInt(), unknown.toInt(), detailCount),
                style: const TextStyle(
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSummary(double percent, int correctTotal,
      int incorrectTotal, int unknownTotal,
      Map<String, int> detailCount) {

    if (correctTotal + incorrectTotal == 0) {
      return "วันนี้ยังไม่มีข้อมูลการนั่งที่ประเมินได้\n"
          "กรุณาปรับเทียบอุปกรณ์ก่อนใช้งานค่ะ";
    }

    if (incorrectTotal == 0) {
      return "ยอดเยี่ยมมาก 👏\n"
          "วันนี้คุณนั่งถูกต้องตลอดทั้งวัน "
          "(${percent.toStringAsFixed(1)}%) รักษาแบบนี้ไว้นะคะ 💚";
    }

    String levelText;

    if (percent >= 80) {
      levelText = "โดยรวมทำได้ดีมาก 💚";
    } else if (percent >= 60) {
      levelText = "วันนี้ทำได้ดีพอสมควร 🙂";
    } else if (percent >= 40) {
      levelText = "วันนี้มีช่วงที่นั่งผิดค่อนข้างบ่อยนะคะ";
    } else {
      levelText = "วันนี้นั่งผิดบ่อยมากเลยนะคะ 💛";
    }

    if (detailCount.isEmpty) {
      return "$levelText\n"
          "วันนี้นั่งผิดทั้งหมด $incorrectTotal ครั้ง\n"
          "ลองระวังท่านั่งให้มากขึ้นอีกนิดนะคะ";
    }

    var sorted = detailCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int topCount = sorted.first.value;

    List<String> topProblems = sorted
        .where((e) => e.value == topCount)
        .map((e) => e.key)
        .toList();

    String joined = topProblems.join(" + ");

    return "$levelText\n"
        "วันนี้นั่งผิดทั้งหมด $incorrectTotal ครั้ง\n"
        "ปัญหาที่พบมากที่สุดคือ \"$joined\"\n"
        "ลองใส่ใจจุดนี้เป็นพิเศษ จะช่วยให้ผลลัพธ์ดีขึ้นมากค่ะ 🌿";
  }
}