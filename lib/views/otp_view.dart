import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo2/views/register_phone_view.dart';
import 'package:demo2/constants/routes.dart';

class OTPScreen extends StatefulWidget {
 

  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late final TextEditingController _otp;
  late String verificationId;
    @override
  void initState() {
    //_phone= TextEditingController();
    _otp=TextEditingController();
     //final String phoneNumber;
  
    
    super.initState();
  }
  @override
  void dispose() {
    //_phone.dispose();
    _otp.dispose();
   
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
      appBar: AppBar(
        title: const Text('Verify phone number'),
      ),
      body: Column(
        children: [
        Spacer(),
        TextField(
          controller: _otp,
          decoration: InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        SizedBox(
          height: 16,
        ),
        TextButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId:  verificationId, smsCode: _otp.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
           // Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
          child: Text("VERIFY"),
          
        ),
        Spacer(),
      ],
      ),
    );
  }


}

