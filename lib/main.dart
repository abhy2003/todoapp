import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todoapp/view/Homescreen.dart';
import 'package:todoapp/view/Loginscreen.dart';
import 'package:todoapp/view/Signupscreen.dart';
import 'package:todoapp/wrapper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  runApp(Myapp());
}


class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page:() =>  Wrapper()),
        GetPage(name: '/login', page: () => Loginscreen(),),
        GetPage(name: '/signup', page: () => Signupscreen(),),
        GetPage(name: '/homescreen', page: () => Homescreen(),)
      ],
    );
  }
}
