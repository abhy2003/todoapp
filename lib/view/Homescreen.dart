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
    String selectedType = 'All';
    String selectedStatus = 'All';
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
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: () {
                filteroption(context);
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
            if (selectedType != 'All') {
              tasks = tasks.where((doc) => doc['type'] == selectedType).toList();
            }
            if (selectedStatus != 'All') {
              tasks = tasks.where((doc) => doc['status'] == selectedStatus).toList();
            }

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
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            editTodo(context, task.id);
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
      String selectedValue = 'Personal';
      final _formKey = GlobalKey<FormState>();

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
              key: _formKey,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a task type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (selectedDate != null) {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Map<String, dynamic> taskData = {
                              'userId': user.uid,
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
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select a due date',
                            snackPosition: SnackPosition.BOTTOM,
                          );
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



    void editTodo(BuildContext context, String taskId) async {
      DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('todo')
          .doc(taskId)
          .get();

      if (taskSnapshot.exists) {
        final task = taskSnapshot.data() as Map<String, dynamic>;
        final TextEditingController taskNameController =
        TextEditingController(text: task['name']);
        final TextEditingController taskDescriptionController =
        TextEditingController(text: task['description']);
        DateTime? selectedDate = task['dueDate'].toDate();
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
            return StatefulBuilder(
              builder: (context, setState) {
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
                                setState(() {
                                  selectedType = value!;
                                });
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
                          onPressed: () async {
                            if (taskNameController.text.isNotEmpty &&
                                taskDescriptionController.text.isNotEmpty &&
                                selectedDate != null) {
                              await FirebaseFirestore.instance
                                  .collection('todo')
                                  .doc(taskId)
                                  .update({
                                'name': taskNameController.text,
                                'description': taskDescriptionController.text,
                                'dueDate': selectedDate,
                                'status': selectedStatus,
                                'type': selectedType,
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
          },
        );
      } else {
        Get.snackbar(
          'Error',
          'Task not found!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get(),
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Name: $name',
                                        style: GoogleFonts.poppins(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          TextEditingController nameController =
                                          TextEditingController(text: name);

                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(style: GoogleFonts.poppins(),'Edit Name'),
                                                content: TextField(
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter new name',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Cancel',style: GoogleFonts.poppins(fontSize: 15.0, color: Colors.redAccent)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      String newName =
                                                      nameController.text.trim();

                                                      if (newName.isNotEmpty) {
                                                        await FirebaseFirestore.instance
                                                            .collection('users')
                                                            .doc(user.uid)
                                                            .update({
                                                          'name': newName,
                                                        });
                                                        Get.back();
                                                      }
                                                    },
                                                    child: Text('Save',style: GoogleFonts.poppins( color: Colors.black)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Email: $email',
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black),
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
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
    void filteroption(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Filter Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedType = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                    DropdownMenuItem(
                      value: 'Personal',
                      child: Text('Personal',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                    DropdownMenuItem(
                      value: 'Work',
                      child: Text('Work',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                  ],
                  hint: Text('Select Type',style: GoogleFonts.poppins(color: Colors.black),),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                    DropdownMenuItem(
                      value: 'Pending',
                      child: Text('Pending',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                    DropdownMenuItem(
                      value: 'Complete',
                      child: Text('Complete',style: GoogleFonts.poppins(color: Colors.black),),
                    ),
                  ],
                  hint: Text('Select Status',style: GoogleFonts.poppins(color: Colors.black),),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel',style: GoogleFonts.poppins(color: Colors.blueAccent),),
              ),
              TextButton(
                onPressed: () {
                 Get.back();
                },
                child: Text('Apply',style: GoogleFonts.poppins(color: Colors.black),),
              ),
            ],
          );
        },
      );
    }
  }
