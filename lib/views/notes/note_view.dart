import 'package:demo2/services/auth/auth_service.dart';
import 'package:demo2/services/crud/notes_service.dart';
import 'package:demo2/services/crud/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan'),),
      body: const Text('Plan your trip here: '),
    );
  }
}