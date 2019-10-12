import 'package:flutter/material.dart';
import 'package:flutter_todo_app_with_hasura/model/todo.dart';
import 'package:flutter_todo_app_with_hasura/service/todo_service.dart';

import 'add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = TodoService();

  final key = GlobalKey<ScaffoldState>();

  void deleteTodo(int id) async {
    await _service.delete(id: id);
    setState((){});
    final snackbar = SnackBar(
      content: Text('Todo deleted!'),
    );
    key.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: FutureBuilder<List<Todo>>(
        key: UniqueKey(),
        future: _service.getAllTodos(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final todos = snapshot.data;
            return ListView.separated(
                key: UniqueKey(),
                itemBuilder: (_, i) => TodoTile(todo: todos[i], onDelete: deleteTodo),
                separatorBuilder: (_, i) => Divider(),
                itemCount: todos.length);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final createdTodo = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddTodoScreen(),
            ),
          );
          if (createdTodo != null) {
            setState(() {});
            final snackbar = SnackBar(
              content: Text('Todo created!'),
            );
            key.currentState.showSnackBar(snackbar);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  TodoTile({this.todo, this.onDelete});

  final Todo todo;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTodoScreen(todo: todo))),
      title: Text(todo.description),
      subtitle: Text(todo.dueDate),
      trailing: IconButton(
        onPressed: () => onDelete(todo.id),
        icon: Icon(Icons.delete_forever),
      ),
    );
  }
}
