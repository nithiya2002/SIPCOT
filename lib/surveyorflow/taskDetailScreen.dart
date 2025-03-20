import 'package:flutter/material.dart';
import 'package:sipcot/customImageUpload.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onCompleted;

  const TaskDetailScreen({super.key, required this.task, required this.onCompleted});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String status = "Pending";
  TextEditingController remarkController = TextEditingController();
  
  // Example values for lat & long (auto-populated)
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    latController.text = widget.task["lat"].toString();
    longController.text = widget.task["lng"].toString();
  }

  void submitForm() {
    if (status == "Pass") {
      widget.onCompleted();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task marked as failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task["name"]),
          bottom: TabBar(
            tabs: [
              Tab(text: "Direction", icon: Icon(Icons.directions)),
              Tab(text: "Form", icon: Icon(Icons.assignment)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text("Map direction feature will be added later")),
            buildForm(),
          ],
        ),
      ),
    );
  }

  Widget buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latitude & Longitude Fields
          buildTextField("Latitude", latController, readOnly: true),
          SizedBox(height: 10),
          buildTextField("Longitude", longController, readOnly: true),
          SizedBox(height: 20),

          // Image Upload Section
          buildSectionTitle("Capture Images"),
          buildImageUploadField(),
          SizedBox(height: 20),

          // Video Capture Section
          buildSectionTitle("Capture Video"),
          buildVideoUploadField(),
          SizedBox(height: 20),

          // Remark Input Field
          buildTextField("Remark", remarkController),
          SizedBox(height: 20),

          // Status Dropdown
          buildSectionTitle("Status"),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: status,
              isExpanded: true,
              underline: SizedBox(),
              items: ["Pending", "Pass", "Fail"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => status = value!),
            ),
          ),
          SizedBox(height: 30),

          // Submit Button
          Center(
            child: ElevatedButton(
              onPressed: submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Submit", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget buildImageUploadField() {
    return Column(
      children: [
        CustomImageUploadField(
          initialImagePath: null,
          text: "Upload Image 1",
          onImageSelected: (file) {
            print("Selected image: ${file.path}");
          },
        ),
        SizedBox(height: 10),
        CustomImageUploadField(
          initialImagePath: null,
          text: "Upload Image 2",
          onImageSelected: (file) {
            print("Selected image: ${file.path}");
          },
        ),
      ],
    );
  }

  Widget buildVideoUploadField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: IconButton(
          icon: Icon(Icons.videocam, size: 30),
          onPressed: () {
            print("Capture Video");
          },
        ),
      ),
    );
  }
}
