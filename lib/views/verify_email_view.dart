import 'package:demo2/constants/routes.dart';
import 'package:demo2/services/auth/auth_service.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'),),
      body: Column(children: [
            const Text('Check your mail for verification'),
            const Text('If you did not recieve any verification, please click below.'),
            TextButton(onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
             child: const Text('Send email verification again')
             ),
             TextButton(onPressed:  () async{
               await AuthService.firebase().logOut();
               Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
             },
             child: const Text('Restart'),)
          ],),
    );
  }
}