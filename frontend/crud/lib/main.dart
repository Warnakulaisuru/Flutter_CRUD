import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List notes = [];
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final String apiUrl = "http://10.0.2.2:5000/api/notes"; // Android emulator (use localhost for iOS/web)

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      setState(() => notes = jsonDecode(res.body));
    }
  }

  Future<void> addNote() async {
    final body = jsonEncode({
      "title": titleCtrl.text,
      "content": contentCtrl.text,
    });
    await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"}, body: body);
    titleCtrl.clear();
    contentCtrl.clear();
    fetchNotes();
  }

  Future<void> deleteNote(String id) async {
    await http.delete(Uri.parse("$apiUrl/$id"));
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes CRUD")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: "Content")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: addNote, child: const Text("Add Note")),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, i) {
                  final note = notes[i];
                  return Card(
                    child: ListTile(
                      title: Text(note["title"]),
                      subtitle: Text(note["content"]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteNote(note["_id"]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
