import 'dart:io';
import 'package:boder/constants/layout/main_layout.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/views/auth/login_screen.dart';
import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/custom_annotated_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(1200, 800),
      center: true,
      backgroundColor: AppColors.blue,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }
   );
  }
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  Get.lazyPut<UsersController>(() => UsersController());
  runApp(
    CustomAnnotatedSheet(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          primaryColor: Colors.cyan,
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            iconTheme: IconThemeData(
              size: 25,
              color: Colors.grey.shade900,
            ),
            centerTitle: true,
            surfaceTintColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.cyan).copyWith(surface: AppColors.white),
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: "/",
        routes: {
          "/" : (page)=> LoginScreen(),
          "/layout" : (page)=> MainLayout(),
        },
      ),
    ),
  );
}
