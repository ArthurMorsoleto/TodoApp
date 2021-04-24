import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/model/Todo.dart';
import 'package:todo_app/screens/todo_list.dart';

class TodoItem extends StatefulWidget {
  final Todo todoItem;
  final int index;

  TodoItem({Key key, this.todoItem, this.index}) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState(todoItem, index);
}

class _TodoItemState extends State<TodoItem> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final key = GlobalKey<ScaffoldState>();
  Todo _todoItem;
  int _index;

  _TodoItemState(Todo todoItem, int index) {
    this._todoItem = todoItem;
    this._index = index;
    if (_todoItem != null) {
      _titleController.text = _todoItem.title;
      _descriptionController.text = _todoItem.description;
    }
  }

  _saveItem() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showSnackBar("both fields should not be empty");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Todo> list = [];
      var data = prefs.getString(KEY_TODO_LIST);
      if (data != null) {
        var objs = jsonDecode(data) as List;
        list = objs.map((e) => Todo.fromJson(e)).toList();
      }

      _todoItem = Todo.from(_titleController.text, _descriptionController.text);

      if (_index != null || _index != -1) {
        list[_index] = _todoItem;
      } else {
        list.add(_todoItem);
      }

      prefs.setString(KEY_TODO_LIST, jsonEncode(list));
      Navigator.pop(context);
    }
  }

  _showSnackBar(String message) {
    ScaffoldMessenger.of(key.currentContext)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar:
          AppBar(backgroundColor: Colors.redAccent, title: Text("Todo Item")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'title',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              controller: _titleController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'description',
                  floatingLabelBehavior: FloatingLabelBehavior.auto),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(onPressed: _saveItem, child: Text("Save"))),
          )
        ],
      ),
    );
  }
}
