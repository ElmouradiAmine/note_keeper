import 'package:flutter/material.dart';
import 'package:note_keeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'note_details.dart';
import 'package:note_keeper/models/note.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        tooltip: 'Add note',
        onPressed: () {
          print('FAB clciked');
          navigateToDetails(Note('', '', 2),'Add note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[index].priority),
              child: getPriorityIcon(this.noteList[index].priority),
            ),
            title: Text(
              this.noteList[index].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[index].date),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
              ),
              onPressed: () {
                _delete(context, this.noteList[index]);
              },
            ),
            onTap: () {
              print('The tile has been pressed!');
              navigateToDetails(this.noteList[index],'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetails(Note note,String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(
        note,title
      );
    }));
    if (result== true){
      updateListView();
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });

  }
}
