import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app_with_hasura/model/todo.dart';
import 'package:flutter_todo_app_with_hasura/model/todo_type.dart';
import 'package:flutter_todo_app_with_hasura/service/todo_service.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  AddTodoScreen({this.todo});

  final Todo todo;

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _todoService = TodoService();
  final _formKey = GlobalKey<FormState>();
  final _format = DateFormat("yyyy-MM-dd");
  var _todoData = {};
  Future<List<TodoType>> _todoTypeFuture;
  int _pickedType;

  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      final todo = widget.todo;
      descriptionController.text = todo.description;
      dueDateController.text = todo.dueDate;
      _pickedType = todo.todoType.id;
    }
    _todoTypeFuture = _todoService.getAllTodoTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add todo'),),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder(),),
                validator: (description) => description.isEmpty ? 'Required field' : null,
                onSaved: (description) => _todoData['description'] = description
              ),

              SizedBox(height: 24),

              DateTimeField(
                controller: dueDateController,
                format: _format,
                decoration: InputDecoration(
                  labelText: 'Due Date', border: OutlineInputBorder(),),
                onSaved: (dueDate) => _todoData['dueDate'] = dueDate,
                validator: (dueDate) => dueDate == null ? 'Required field' : null,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
              ),

              SizedBox(height: 24),

              FutureBuilder<List<TodoType>>(
                future: _todoTypeFuture,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return DropDownFormField(
                      titleText: 'Todo Type',
                      value: _pickedType,
                      onChanged: (todoType) => setState(() =>_pickedType = todoType),
                      onSaved: (todoType) => _todoData['todoType'] = todoType,
                      validator: (todoType) => todoType == null ? 'Required field' : null,
                      dataSource: getDatasource(snapshot.data),
                      textField: 'display',
                      valueField: 'value',
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      await _todoService.save(
                        description: _todoData['description'],
                        dueDate: _format.format(_todoData['dueDate']),
                        todoType: _todoData['todoType']
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text('Add Todo', style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getDatasource(List<TodoType> todoTypes) {
    return List.generate(todoTypes.length, (i) => {
      'value': todoTypes[i].id,
      'display': todoTypes[i].description
    });
  }
}
