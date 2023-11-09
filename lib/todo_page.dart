import 'package:flutter/material.dart';
import 'package:proyek_todolist/database_helper.dart';
import 'package:proyek_todolist/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TodoList();  
}

class _TodoList extends State<TodoList> {
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _deskripsiCtrl = TextEditingController();
  TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = [];

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todoList = todos;
    });
  }

  void addItem() async {
    await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    //todoList.add(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    refreshList();

    _namaCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void updateItem(int index, bool done) async {
      todoList[index].done = done;  
      await dbHelper.updateTodo(todoList[index]);
       refreshList();
  }

  void deleteItem(int id) async {
    //todoList.removeAt(index);
    await dbHelper.deleteTodo(id);
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if(teks.isEmpty){
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos;
    });
  }

  void tampilForm() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.all(20),
            title: Text("Tambah Todo"),
            actions: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
              }, style: ElevatedButton.styleFrom(
      primary: Colors.brown),
               child: Text("Tutup")),
              ElevatedButton(onPressed: () {
                addItem();
                Navigator.pop(context);
              }, style: ElevatedButton.styleFrom(
      primary: Colors.brown),
               child: Text('Tambah'))
      ],
      content: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            TextField(
              controller: _namaCtrl,
              decoration: InputDecoration(hintText: 'Nama Todo'),
            ),
            TextField(
              controller: _deskripsiCtrl,
              decoration: InputDecoration(hintText: 'Deskripsi Pekerjaan'),
            ),
        ],),
      ),
    ));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Todo List',
        style: TextStyle(fontStyle: FontStyle.italic),),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilForm();
        },
        child: Icon(Icons.add_box),
        backgroundColor: Colors.brown,
        ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                cariTodo();
              },
            decoration: InputDecoration(
              hintText: 'Cari Disini', 
              prefixIcon: Icon(Icons.search), 
              border: OutlineInputBorder()),
            ),
            ),
          Expanded(
            child: ListView.builder(
                itemCount: todoList.length,
                itemBuilder: (context, index){
                  return ListTile(
                    leading: todoList[index].done 
                    ? IconButton(
                      icon: const Icon(Icons.check_circle), 
                      onPressed: () {
                        updateItem(index, !todoList[index].done);
                      },
                    )
                    : IconButton(
                      icon: const Icon(Icons.radio_button_unchecked), 
                      onPressed: () {
                        updateItem(index, !todoList[index].done);
                      },
                    ),
                    title: Text(todoList[index].nama,),
                    subtitle: Text(todoList[index].deskripsi),
                    trailing: IconButton(icon: Icon(Icons.delete_forever_outlined),
                    onPressed: () {
                     showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Konfirmasi Hapus"),
                content: Text("Apakah Anda yakin ingin menghapus '${todoList[index].nama}'?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                    },
                    child: Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteItem(todoList[index].id ?? 0);
                      Navigator.pop(context); // Tutup dialog setelah tindakan selesai
                    },
                    child: Text("Ya"),
                  )]));
                    },
                    ),
                    );  
            })
            ),
        ],
      ),

      
    );
  }
  
}