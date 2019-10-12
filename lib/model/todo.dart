import 'todo_type.dart';

class Todo {
  int id;
  String description;
  String dueDate;
  TodoType todoType;

  Todo({this.id, this.description, this.dueDate, this.todoType});

  Todo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    dueDate = json['due_date'];
    todoType = json['todo_type'] != null
        ? new TodoType.fromJson(json['todo_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['due_date'] = this.dueDate;
    if (this.todoType != null) {
      data['todo_type'] = this.todoType.toJson();
    }
    return data;
  }
}