import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history_page.dart';

class DashboardPage extends StatefulWidget {
  final String deviceName;

  const DashboardPage({
    super.key,
    required this.deviceName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DatabaseReference ref;

  List<Map<String, dynamic>> historyList = [];

  double currentPitch = 0;
  double currentRoll = 0;
  String currentPosture = "unknown";

  @override
  void initState() {
    super.initState();

    ref = FirebaseDatabase.instance
        .ref("${widget.deviceName}/history");

    listenHistory();
  }

  void listenHistory() {
    ref.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        return;
      }

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
              });
            }
          });
        }
      });

      tempList.sort(
        (a, b) => "${b["date"]} ${b["time"]}"
            .compareTo("${a["date"]} ${a["time"]}"),
      );

      setState(() {
        historyList = tempList.take(10).toList();

        if (historyList.isNotEmpty) {
          currentPitch = historyList.first["pitch"];
          currentRoll = historyList.first["roll"];
          currentPosture = historyList.first["posture"];
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
      default:
        return Colors.grey;
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
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
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
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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
                          builder: (_) => HistoryPage(
                            deviceName: widget.deviceName,
                          ),
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

              // ===== POSTURE STATUS =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Current Posture",
                      style:
                          TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentPosture == "correct"
                          ? "Sitting Correct"
                          : "Sitting Incorrect",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            postureColor(currentPosture),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Latest History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ===== HISTORY LIST =====
              Expanded(
                child: historyList.isEmpty
                    ? const Center(
                        child: Text("No Data"),
                      )
                    : ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item =
                              historyList[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset:
                                      const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item["date"]}  ${item["time"]}",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Pitch: ${item["pitch"]}° | Roll: ${item["roll"]}°",
                                    ),
                                  ],
                                ),
                                Text(
                                  item["posture"],
                                  style: TextStyle(
                                    color: postureColor(
                                        item["posture"]),
                                    fontWeight:
                                        FontWeight.bold,
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