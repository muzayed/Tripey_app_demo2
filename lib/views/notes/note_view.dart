import 'package:demo2/services/auth/auth_service.dart';
import 'package:demo2/services/crud/notes_service.dart';
import 'package:demo2/services/crud/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
//import 'dart:html';
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;
  
  @override
  void initState(){
    _noteService= NoteService();
    _textController= TextEditingController();
    super.initState();
  }
  void _textControllerListener() async{
    final note= _note;
    if (note== null){
      return;
    }
    await _noteService.updateNote(note: note, text: _textController.text);
  }
  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future <DatabaseNote> createNewNote() async {
    final existingNote= _note;
    if (existingNote!= null){
      return existingNote;
    } 
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    return await _noteService.createNote(owner: owner);
  }
  void _deleteNoteIfTextIsEmpty() {
    final note= _note;
    if (_textController.text.isEmpty && note!= null){
      _noteService.deleteNote(id: note.id);
    }
  }
  void _saveNoteIfTextNotEmpty() async{
    final note= _note;
    
    if (note!= null && _textController.text.isNotEmpty ){
      await _noteService.updateNote(note: note, text: _textController.text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan'),),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
          
            case ConnectionState.done:
              _note= snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,

              );
            default :
              return const CircularProgressIndicator();
          }
        },
        ),
    );
  }
}