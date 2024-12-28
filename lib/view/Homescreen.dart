import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/view/Loginscreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> tasks = [];
  String selectedValue = 'Personal';
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final isLoggedIn = await GetStorage.init();
    if (!isLoggedIn) {
      Get.offAll(() => Loginscreen());
    }
  }

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
                    'Status: ${task['status']}\n'
                    'Type: ${task['type']}',
                style: GoogleFonts.poppins(),
              ),

              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        editTask(context, tasks.indexOf(task));
                      },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteTask(context, tasks.indexOf(task));
                    },
                  ),
                  Switch(
                    value: task['status'] == 'Complete',
                    onChanged: (bool value) {
                      setState(() {
                        task['status'] = value ? 'Complete' : 'Pending';
                      });
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
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
    String selectedValue = 'Personal';

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
                    SizedBox(height: 20,),
                    Spacer(),
                    DropdownButton<String>(
                      value: selectedValue,
                      items: [
                        DropdownMenuItem(
                          value: 'Personal',
                          child: Text('Personal'),
                        ),
                        DropdownMenuItem(
                          value: 'Work',
                          child: Text('Work'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                        });
                      },
                      hint: Text('Select an option'),
                    ),
                    SizedBox(width: 10),
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
                  setState(() {
                    tasks.add({
                      'name': taskNameController.text,
                      'description': taskDescriptionController.text,
                      'dueDate': selectedDate,
                      'status': selectedStatus,
                      'type': selectedValue,
                    });
                  });
                  Get.back();
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
  void editTask(BuildContext context, int taskIndex) {
    final task = tasks[taskIndex];
    final TextEditingController taskNameController =
    TextEditingController(text: task['name']);
    final TextEditingController taskDescriptionController =
    TextEditingController(text: task['description']);
    DateTime? selectedDate = task['dueDate'];
    String selectedStatus = task['status'];
    String selectedType = task['type'];

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
                  'Edit Task',
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
                    DropdownButton<String>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(
                          value: 'Personal',
                          child: Text('Personal'),
                        ),
                        DropdownMenuItem(
                          value: 'Work',
                          child: Text('Work'),
                        ),
                      ],
                      onChanged: (value) {
                        selectedType = value!;
                      },
                      hint: Text('Select Type'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
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
                      setState(() {
                        tasks[taskIndex] = {
                          'name': taskNameController.text,
                          'description': taskDescriptionController.text,
                          'dueDate': selectedDate,
                          'status': selectedStatus,
                          'type': selectedType,
                        };
                      });
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Update Task',
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
  void deleteTask(BuildContext context, int taskIndex) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeAt(taskIndex);
              });
              Get.back();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
