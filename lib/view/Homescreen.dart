  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:get/get_core/src/get_main.dart';
  import 'package:google_fonts/google_fonts.dart';

import '../controller/authcontroller.dart';

  class Homescreen extends StatefulWidget {
    const Homescreen({super.key});

    @override
    State<Homescreen> createState() => _HomescreenState();
  }

  class _HomescreenState extends State<Homescreen> {
    List<Map<String, dynamic>> tasks = [];
    String selectedValue = 'Personal';
    final AuthController authController = Get.put(AuthController());

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed:() {
                profilescreen(context);
              },
            ),
          ],
          backgroundColor: Colors.orange,
          title: Text("Todo App",style: GoogleFonts.poppins(),),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('todo')
              .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No tasks found.'));
            }

            var tasks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                var task = tasks[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(
                      task['name'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Description: ${task['description']}\n'
                          'Due Date: ${task['dueDate'].toDate().toString().split(' ')[0]}\n'
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
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('todo')
                                .doc(task.id)
                                .delete();
                          },
                        ),
                        Switch(
                          value: task['status'] == 'Complete',
                          onChanged: (bool value) {
                            FirebaseFirestore.instance
                                .collection('todo')
                                .doc(task.id)
                                .update({
                              'status': value ? 'Complete' : 'Pending',
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
      final TextEditingController taskDescriptionController = TextEditingController();
      DateTime? selectedDate;
      String selectedStatus = 'Pending';
      String selectedValue = 'Personal'; // Default dropdown value

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
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    items: ['Personal', 'Work']
                        .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(),
                      ),
                    ))
                        .toList(),
                    onChanged: (newValue) {
                      selectedValue = newValue!;
                    },
                    decoration: InputDecoration(
                      labelText: 'Task Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (taskNameController.text.isNotEmpty &&
                          taskDescriptionController.text.isNotEmpty &&
                          selectedDate != null) {
                        // Get current user UID
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Map<String, dynamic> taskData = {
                            'userId': user.uid, // Include the user's UID
                            'name': taskNameController.text,
                            'description': taskDescriptionController.text,
                            'dueDate': selectedDate,
                            'status': selectedStatus,
                            'type': selectedValue,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          await FirebaseFirestore.instance
                              .collection('todo')
                              .add(taskData);

                          Get.back();
                        }
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
    void profilescreen(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Stack(
              children: [
                Positioned(
                  top: 50,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error loading user data.'));
                          } else if (snapshot.hasData) {
                            var userDoc = snapshot.data;
                            var name = userDoc?['name'] ?? 'No name available';
                            var email = userDoc?['email'] ?? 'No email available';

                            print('User Info: Name: $name, Email: $email');

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profile',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Name: $name',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Email: $email',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black
                                    ),
                                    child: Text('Logout',style: GoogleFonts.poppins(color: Colors.white),),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(child: Text('No data available.'));
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
