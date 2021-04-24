import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/model/Todo.dart';
import 'package:todo_app/screens/todo_item.dart';

const KEY_TODO_LIST = "KEY_TODO_LIST";

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> todoList = [];
  final doneStyle =
      TextStyle(color: Colors.green, decoration: TextDecoration.lineThrough);

  @override
  void initState() {
    super.initState();
    _reloadList();
  }

  _reloadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(KEY_TODO_LIST);
    if (data != null) {
      setState(() {
        var objs = jsonDecode(data) as List;
        todoList = objs.map((e) => Todo.fromJson(e)).toList();
      });
    }
  }

  _deleteItem(int index) async {
    setState(() {
      todoList.removeAt(index);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_TODO_LIST, jsonEncode(todoList));
  }

  _markItemAsDone(int index) async {
    setState(() {
      todoList[index].isFinished = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_TODO_LIST, jsonEncode(todoList));
  }

  _showAlertDialog(
      {String title, String content, Function confirmFunction, int index}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context), child: Text("não")),
              FlatButton(
                  onPressed: () {
                    confirmFunction(index);
                    Navigator.pop(context);
                  },
                  child: Text("sim"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TodoApp"),
        centerTitle: false,
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TodoItem(
                          todoItem: todoList[index],
                          index: index))).then((value) => _reloadList()),
              title: Text('${todoList[index].title}',
                  style: todoList[index].isFinished ? doneStyle : null),
              subtitle: Text('${todoList[index].description}',
                  style: todoList[index].isFinished ? doneStyle : null),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                      visible: !todoList[index].isFinished,
                      child: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _showAlertDialog(
                              title: "confirm",
                              content: "mark this item as done?",
                              confirmFunction: _markItemAsDone,
                              index: index))),
                  IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _showAlertDialog(
                          title: "confirm",
                          content: "delete this item?",
                          confirmFunction: _deleteItem,
                          index: index)),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: todoList.length),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => TodoItem()))
            .then((value) => _reloadList()),
      ),
    );
  }
}
