import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history_page.dart';
import 'services/notification_service.dart';

class DashboardPage extends StatefulWidget {
  final String deviceName;

  const DashboardPage({super.key, required this.deviceName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

int incorrectStreak = 0;
String? lastNotifiedTime;

class _DashboardPageState extends State<DashboardPage> {
  late final DatabaseReference ref;

  List<Map<String, dynamic>> historyList = [];

  double currentPitch = 0;
  double currentRoll = 0;
  String currentPosture = "unknown";
  String currentPostureDetail = "";

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref("${widget.deviceName}/history");
    listenHistory();
  }

  void listenHistory() {
    ref.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) return;

      final Map<dynamic, dynamic> historyData = data;
      List<Map<String, dynamic>> tempList = [];

      historyData.forEach((date, dateValue) {
        if (dateValue is Map) {
          dateValue.forEach((time, value) {
            if (value is Map) {
              tempList.add({
                "date": date,
                "time": time.toString().replaceAll("-", ":"),
                "pitch": (value["pitch"] ?? 0).toDouble(),
                "roll": (value["roll"] ?? 0).toDouble(),
                "posture": value["posture"] ?? "unknown",
                "postureDetail": value["postureDetail"]?.toString() ?? "",
              });
            }
          });
        }
      });

      tempList.sort(
        (a, b) =>
            "${b["date"]} ${b["time"]}".compareTo("${a["date"]} ${a["time"]}"),
      );

      setState(() {
        historyList = tempList.take(10).toList();

        if (historyList.isNotEmpty) {
          final latest = historyList.first;

          currentPitch = latest["pitch"];
          currentRoll = latest["roll"];
          currentPosture = latest["posture"];
          currentPostureDetail = latest["postureDetail"];

          String currentTimeKey = "${latest["date"]}_${latest["time"]}";

          /// 🔢 นับ incorrect ติดต่อกัน
          if (currentPostureDetail == "incorrect") {
            incorrectStreak++;
          } else {
            incorrectStreak = 0;
          }

          /// 🔔 แจ้งเมื่อครบ 3 ครั้ง และยังไม่เคยแจ้ง entry นี้
          if (incorrectStreak >= 3 && lastNotifiedTime != currentTimeKey) {
            NotificationService.showIncorrectPostureLocal();

            lastNotifiedTime = currentTimeKey;
          }
        }
      });
    });
  }

  Color postureColor(String posture) {
    switch (posture) {
      case "correct":
        return const Color(0xFF6E9F8D);
      case "incorrect":
        return Colors.redAccent;
      case "unknown":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String postureText(String posture) {
    switch (posture) {
      case "correct":
        return "Sitting Correct";
      case "incorrect":
        return "Sitting Incorrect";
      case "unknown":
        return "Not Calibrated";
      default:
        return "Unknown";
    }
  }

  String postureDetailText(String posture, String detail) {
    switch (posture) {
      case "correct":
        return "ท่านั่งปกติ";
      case "incorrect":
        return detail.isNotEmpty ? detail : "ท่านั่งไม่ถูกต้อง";
      case "unknown":
        return "กรุณาปรับเทียบอุปกรณ์ก่อนใช้งาน";
      default:
        return "";
    }
  }

  Widget buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF6E9F8D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite, color: Colors.white),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dashboard - ${widget.deviceName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HistoryPage(deviceName: widget.deviceName),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== STAT CARDS =====
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        "Pitch",
                        "${currentPitch.toStringAsFixed(1)}°",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: buildStatCard(
                        "Roll",
                        "${currentRoll.toStringAsFixed(1)}°",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== CURRENT POSTURE =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Current Posture",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      postureText(currentPosture),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: postureColor(currentPosture),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      postureDetailText(currentPosture, currentPostureDetail),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Latest History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // ===== HISTORY LIST =====
              Expanded(
                child: historyList.isEmpty
                    ? const Center(child: Text("No Data"))
                    : ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item["date"]}  ${item["time"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Pitch: ${item["pitch"]}° | Roll: ${item["roll"]}°",
                                    ),
                                    if ((item["postureDetail"] ?? "")
                                        .toString()
                                        .isNotEmpty)
                                      Text(
                                        item["postureDetail"].toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  item["posture"].toString().toUpperCase(),
                                  style: TextStyle(
                                    color: postureColor(item["posture"]),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
