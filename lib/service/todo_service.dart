import 'package:flutter_todo_app_with_hasura/model/todo.dart';
import 'package:flutter_todo_app_with_hasura/model/todo_type.dart';
import 'package:hasura_connect/hasura_connect.dart';

class TodoService {
  HasuraConnect hasuraConnect = HasuraConnect(
      'https://flutter-todo-app-with-hasura.herokuapp.com/v1/graphql');

  Future<List<Todo>> getAllTodos() async {
    Map response = await hasuraConnect.query(
      '''
        query {
          todo {
            description
            id
            due_date
            todo_type {
              id
              description
            }
          }
        }
      '''
    );

    List todoList = response['data']['todo'];
    return List.generate(
      todoList.length, (index) => Todo.fromJson(todoList[index]),
    );
  }

  Future<List<TodoType>> getAllTodoTypes() async {
    Map response = await hasuraConnect.query(
      '''
        query {
          todo_type {
            id
            description
          }
        }
      '''
    );

    List todoTypeList = response['data']['todo_type'];
    return List.generate(
      todoTypeList.length, (index) => TodoType.fromJson(todoTypeList[index]),
    );
  }

  Future<void> save({String description, String dueDate, int todoType}) async {
    hasuraConnect.mutation(
      '''
        mutation MyMutation(\$dueDate: date!, \$description: String!, \$todoType: Int!) {
          insert_todo(objects: {due_date: \$dueDate, description: \$description, type_id: \$todoType}) {
            affected_rows
          }
        }
      ''', variables: {
        'dueDate': dueDate,
        'description': description,
        'todoType': todoType
      }
    );
  }

  Future<void> delete({int id}) async {
    hasuraConnect.mutation(
        '''
          mutation delete_todo(\$id: Int!) {
            delete_todo(
              where: {id: {_eq: \$id}}
            ) {
              affected_rows
            }
          }
      ''', variables: { 'id': id }
    );
  }
}
