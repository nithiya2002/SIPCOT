import 'package:flutter/material.dart';
import 'package:sipcot/surveyorflow/taskDetailScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> pendingTasks = [
    {"id": 1, "name": "Field 1", "lat": 12.9716, "lng": 77.5946},
    {"id": 2, "name": "Field 2", "lat": 13.0827, "lng": 80.2707},
  ];

  List<Map<String, dynamic>> completedTasks = [];

  void moveToCompleted(int index) {
    setState(() {
      completedTasks.add(pendingTasks[index]);
      pendingTasks.removeAt(index);
    });
  }

  void showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text("View Profile"), onTap: () {}),
            ListTile(title: Text("Logout"), onTap: () {}),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => showProfileMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TaskList(
              title: "Pending Tasks",
              tasks: pendingTasks,
              onTap: (task, index) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(
                      task: task,
                      onCompleted: () => moveToCompleted(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TaskList(
              title: "Completed Tasks",
              tasks: completedTasks,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> tasks;
  final Function(Map<String, dynamic>, int)? onTap;

  TaskList({required this.title, required this.tasks, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]["name"]),
                  subtitle: Text("Lat: ${tasks[index]["lat"]}, Lng: ${tasks[index]["lng"]}"),
                  onTap: onTap != null ? () => onTap!(tasks[index], index) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
