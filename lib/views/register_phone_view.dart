import 'package:demo2/constants/routes.dart';
import 'package:demo2/services/auth/auth_exceptions.dart';
import 'package:demo2/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import '../firebase_options.dart';
//import 'dart:developer' as devtools show log;

import '../utilities/show_error_dialog.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class RegisterPhoneView extends StatefulWidget {
  const RegisterPhoneView({super.key});

  @override
  State<RegisterPhoneView> createState() => _RegisterPhoneViewState();
}

class _RegisterPhoneViewState extends State<RegisterPhoneView> {
    MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  late final TextEditingController _phone;
  late String verificationId;
  
  @override
  void initState() {
    _phone= TextEditingController();
    
   // _otp=TextEditingController();
    
    super.initState();
  }
  @override
  void dispose() {
    _phone.dispose();
   // _otp.dispose();
   
    super.dispose();
  }
  
void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    

    try {
      final authCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

     

      if(authCredential.user != null){
        Navigator.of(context).pushNamedAndRemoveUntil(myAppRoute, (route) => false);
      }

    } on FirebaseAuthException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Authentication'),
      ),
      body: Column(
            children: [
              TextField(
                controller: _phone,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Phone Number'),
              ),
              
              TextButton(onPressed: () async {
                //String phoneNumber= _phone.text;
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: _phone.text,
              verificationCompleted: (phoneAuthCredential) async {
              
                signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              verificationFailed: (verificationFailed) async {
              },
              codeSent: (verificationId, resendingToken) async {
                  setState(() {
                  //showLoading = false;
                  currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                  this.verificationId = verificationId;
                });
                
              },
              codeAutoRetrievalTimeout: (verificationId) async {},
            );
            Navigator.of(context).pushNamed(otpRoute);
                
                // try {
                // await AuthService.firebase().createUserPhone(phoneNumber: phoneNumber);
                //   final user= AuthService.firebase().currentUser;
                //   AuthService.firebase().sendEmailVerification();
                //   Navigator.of(context).pushNamed(otpRoute);
                
                // }
                // on WeakPasswordAuthException{
                //   await showErrorDialog(context, 'Password is not strong enough');
                // }
                // on EmailAlreadyInUseAuthException{
                //   await showErrorDialog(context, 'Email is already in use');
                // }
                // on InvalidEmailAuthException{
                //   await showErrorDialog(context, 'Invalid email');
                // }
                // on GenericAuthException{
                //   await showErrorDialog(context,'Authentication Error');
                // }
                 
              }, 
              child: const Text('Next'),),
              
            ],
            
          ),
          
    );
  }

     final _auth = FirebaseAuth.instance;
  
  @override
  Widget trec(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Home Screen"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          await _auth.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}