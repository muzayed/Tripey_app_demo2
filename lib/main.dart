//import 'package:demo2/views/login_view.dart';
//import 'package:demo2/views/login_view.dart';
//import 'package:demo2/views/register_view.dart';
//import 'package:demo2/views/login_view.dart';
//import 'dart:html';
import 'package:demo2/constants/routes.dart';
import 'package:demo2/services/auth/auth_service.dart';
import 'package:demo2/views/login_view.dart';

import 'package:demo2/views/my_app_view.dart';
import 'package:demo2/views/notes/note_view.dart';
import 'package:demo2/views/otp_view.dart';
import 'package:demo2/views/register_phone_view.dart';

import 'package:demo2/views/register_view.dart';
import 'package:demo2/views/verify_email_view.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_options.dart';

//import 'dart:developer' as devtools show log;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(),
      routes: {
      loginRoute:(context) => const LoginView(),
      registerRoute:(context) => const RegisterView(),
      myAppRoute:(context) => const MyappView(),
      verifyMailRoute:(context) => const VerifyEmailView(),
      phoneRoute:(context) => const RegisterPhoneView(),
      otpRoute:(context) => const OTPScreen(),
      noteViewRoute:(context) => const NotesView(),
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            
            case ConnectionState.done:
            final user= AuthService.firebase().currentUser;
            if (user!= null){
           
            return const MyappView();
            } else {
               return const LoginView();
           
            }
            
              default:
              return const CircularProgressIndicator();
          }
          
        },
         
      );

  }
  
}



