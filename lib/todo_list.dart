import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_test/global/global.dart';
import 'package:intl/intl.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Map<String, dynamic>> listData = [];
  List<Map<String, dynamic>> filteredListData = [];
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];

  

  Future<void> addTODO(Map<String, dynamic> newTODO) async {
    await TODOBox.add(newTODO);
    TaskData();

    Navigator.pop(context);
    title.text = '';
    task.text = '';
  }

@override
  void initState() {
    super.initState();
    TaskData();
  }
  void TaskData() {
    final data = TODOBox.keys.map((key) {
      final value = TODOBox.get(key);
      return {
        "key": key,
        "title": value["title"],
        "description": value["description"],
        "checked": false,
        "lastEdit": DateTime.now(),
      };
    }).toList();
    setState(() {
      listData = data.reversed.toList();
      filteredListData = listData;
    });
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat.yMMMMd();
    return formatter.format(dateTime);
  }

  TextEditingController title = TextEditingController();
  TextEditingController task = TextEditingController();

  Future<void> deleteTODO(int id) async {
    await TODOBox.delete(id);
    TaskData();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An item has been deleted')));
  }

  void onSearchTask(String searchText) {
    final filteredList = listData.where((task) {
      final title = task['title'] as String;
      return title.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
    setState(() {
      filteredListData = filteredList;
    });
  }

  void toggleTaskChecked(int index, bool newValue) {
    setState(() {
      filteredListData[index]['checked'] = newValue;
      if (newValue) {
        selectedItems.add(filteredListData[index]);
      } else {
        selectedItems.remove(filteredListData[index]);
      }
    });
  }

  void editTask(int index) {
    TextEditingController titleController = TextEditingController(
        text: filteredListData[index]['title']);
    TextEditingController taskController = TextEditingController(
        text: filteredListData[index]['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: null,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'title'),
                controller: titleController,
              ),
              TextField(
                maxLength: null,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'description'),
                controller: taskController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filteredListData[index]['title'] = titleController.text;
                  filteredListData[index]['description'] = taskController.text;
                  filteredListData[index]['lastEdit'] = DateTime.now();
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void deleteSelectedItems() {
    for (final item in selectedItems) {
      final key = item['key'];
      deleteTODO(key);
    }
    selectedItems.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected items have been deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("All Task"),
        actions: const [
          CircleAvatar(
            child: Icon(Icons.person),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: onSearchTask,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Search",
                prefixIcon: const Icon(Icons.search_rounded),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: filteredListData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = filteredListData[index];
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(166, 113, 187, 183),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: item['checked'],
                          onChanged: (newValue) {
                            toggleTaskChecked(index, newValue!);
                          },
                        ),
                        title: Text(item['title']),
                        subtitle: Text(
                            "${item['description']} \n\nLast edit: ${_formatDate(item['lastEdit']).toString()}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                editTask(index);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteTODO(listData[index]['key']);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  selectedItems.isNotEmpty
                      ? FloatingActionButton(
                          heroTag: "btn1",
                          backgroundColor: Colors.red,
                          onPressed: deleteSelectedItems,
                          child: const Icon(Icons.delete),
                        )
                      : SizedBox(),
                  const Spacer(),
                  FloatingActionButton(
                    heroTag: "btn2",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text("Task"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  maxLength: null,
                                  autofocus: true,
                                  decoration:
                                      const InputDecoration(hintText: 'title'),
                                  controller: title,
                                ),
                                TextField(
                                  controller: task,
                                  maxLength: null,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                      hintText: 'description'),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (title.text.isNotEmpty &&
                                      task.text.isNotEmpty) {
                                    setState(() {
                                      addTODO({
                                        'title': title.text,
                                        'description': task.text,
                                        'checked': false,
                                      });
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Enter title & task");
                                  }
                                },
                                child: const Text("ADD"),
                              ),
                            ],
                          );
                        }),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
