import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> tasks = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed:() {

            },
          ),
        ],
        backgroundColor: Colors.orange,
        title: Text("Todo App",style: GoogleFonts.poppins(),),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                task['name'],
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Description: ${task['description']}\n'
                    'Due Date: ${task['dueDate'].toLocal().toString().split(' ')[0]}\n'
                    'Status: ${task['status']}',
                style: GoogleFonts.poppins(),
              ),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                    },
                  ),
                  Switch(
                    value: task['status'] == 'Complete',  // Toggle based on task's status
                    onChanged: (bool value) {
                      setState(() {
                        // Update the task status here
                        task['status'] = value ? 'Complete' : 'Pending';
                      });
                    },
                    activeColor: Colors.green,  // Color for the switch when it's active
                    inactiveThumbColor: Colors.grey, // Color for the switch when inactive
                  ),
                ],
              ),
              ),
          );
        },
      ),

floatingActionButton: FloatingActionButton(backgroundColor:Colors.orange,onPressed: () {
  tododatasheet(context);
      },
      child: Icon(CupertinoIcons.plus_app_fill,color: Colors.black,),),
    );
  }

  void tododatasheet(BuildContext context) {
    final TextEditingController taskNameController = TextEditingController();
    final TextEditingController taskDescriptionController =
    TextEditingController();
    DateTime? selectedDate;
    String selectedStatus = 'Pending';

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Add Task',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: taskDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Due Date: ${selectedDate != null ? selectedDate?.toLocal().toString().split(' ')[0] : 'Not selected'}',
                      style: GoogleFonts.poppins(),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        'Pick Date',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (taskNameController.text.isNotEmpty &&
                        taskDescriptionController.text.isNotEmpty &&
                        selectedDate != null) {
                      // Add task to the list
                      setState(() {
                        tasks.add({
                          'name': taskNameController.text,
                          'description': taskDescriptionController.text,
                          'dueDate': selectedDate,
                          'status': selectedStatus,
                        });
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Save Task',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
  );
  }
}
