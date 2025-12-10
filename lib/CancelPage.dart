import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages

class CancelPage extends StatefulWidget {
  const CancelPage({super.key});

  @override
  State<CancelPage> createState() => _CancelPageState();
}

class _CancelPageState extends State<CancelPage> {
  List<Map<String, String>> tasks = [];

  final List<Map<String, String>> initialTasks = [
    {'task': 'Pruning plants', 'time': '21:00 PM'},
    {'task': 'Watering plants', 'time': '21:00 PM'},
    {'task': 'Fertilizing plants', 'time': '09:00 AM'},
    {'task': 'Checking soil moisture', 'time': '15:00 PM'},
  ];

  @override
  void initState() {
    super.initState();
    tasks = List.from(initialTasks); // Initialize tasks with initialTasks
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF3F5F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: screenWidth,
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 38.0, left: 10),
                        child: Text.rich(
                          TextSpan(
                            text: "Set ",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: "Reminder",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: Color(0xFF4C6B44),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 38.0, right: 10),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio:
                        4.5, // Adjusted aspect ratio to make cards taller
                    children: [
                      TaskStatusCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CancelPage(),
                            ),
                          );
                        },
                        title: "Cancel",
                        color: Color(0xFFD85C5C),
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "All tasks",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),

          // Task List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskItem(
                    title: tasks[index]['task']!, // Get task name
                    time: tasks[index]['time']!, // Get time
                    icon: Icons.cancel_outlined, // Default icon
                    height: 70, // Increased height
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Task Status Card Widget
class TaskStatusCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final GestureTapCallback? onTap;

  const TaskStatusCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task Item Widget
class TaskItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final double height;

  const TaskItem({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
