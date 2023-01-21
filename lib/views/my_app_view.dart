

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo2/services/auth/auth_service.dart';
import 'package:demo2/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

class MyappView extends StatefulWidget {
  const MyappView({super.key});

  @override
  State<MyappView> createState() => _MyappViewState();
}

class _MyappViewState extends State<MyappView> {
  late final NoteService _notesService;
  String get userEmail=> AuthService.firebase().currentUser!.email!;
  @override
  void initState() {
    _notesService= NoteService();
    
    super.initState();
  }
  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: const Text('Tripey App'),
       actions: [
        IconButton(onPressed: () {Navigator.of(context).pushNamed(noteViewRoute);},
         icon: const Icon(Icons.add),
         ),
        PopupMenuButton <MenuAction>(
          onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
                final shouldLogOut = await showLogOutDialog(context);
                if (shouldLogOut){
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                }
                break;
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem <MenuAction>(
              value: MenuAction.logout,
              child: Text('Log Out'),
            ),
            
            ];
          },
          )
       ],
      ),
      body:FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail) ,
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            
            case ConnectionState.done:
              return StreamBuilder(stream: _notesService.allNotes ,
              builder: (context, snapshot) {
              switch(snapshot.connectionState){
              
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Text('Waiting for the notes...');
                default: return const CircularProgressIndicator();
              } 
              },);
              
            default: return const CircularProgressIndicator();

        }
        
      },)
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
  context: context, 
  builder: (context) {
  return  AlertDialog(
    title:  const Text('Sign out'),
    content: const Text("Are you sure you want to sign out?"),
    actions: [
      TextButton(onPressed: () {
        Navigator.of(context).pop(false);
      },
       child: const Text('Cancel')),
       TextButton(onPressed: () {
        Navigator.of(context).pop(true);
       },
       child: const Text('OK'))
    ],

  ) ; 
  },
  ).then((value) => value ?? false);
}