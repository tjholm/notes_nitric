import 'dart:convert';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app/models/note.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CachedQuery.instance.configFlutter(
    config: QueryConfigFlutter(
      refetchOnConnection: true,
      refetchOnResume: true,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () async {
                debugPrint('Create note');
                await createNoteMutation.mutate(
                  const CreateNoteBody(title: 'Title', content: 'Content'),
                );
                await notesQuery.refetch();
              },
              child: const Text('Create note'),
            ),
          ],
        ),
        body: QueryBuilder(
          query: notesQuery,
          builder: (context, state) {
            if (state.status == QueryStatus.initial || state.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.status == QueryStatus.error) {
              return Text(
                state.error.toString(),
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                final note = state.data!.notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: Builder(builder: (context) {
                    return IconButton(
                      onPressed: () async {
                        await deleteMutation.mutate(note.id);
                        notesQuery.refetch();
                      },
                      icon: const Icon(Icons.delete),
                    );
                  }),
                );
              },
              itemCount: state.data?.notes.length,
            );
          },
        ),
      ),
    );
  }
}

final notesQuery = Query<NotesResponse>(
  queryFn: () async {
    final uri = Uri.parse('$apiUrl/notes');
    final res = await http.get(uri);

    return NotesResponse.fromMap(jsonDecode(res.body));
  },
  key: ["notes"],
);

final deleteMutation = Mutation<void, int>(
  queryFn: (id) async {
    final uri = Uri.parse('$apiUrl/notes/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204) throw Error();
  },
);

final createNoteMutation = Mutation<void, CreateNoteBody>(
  queryFn: (arg) async {
    debugPrint('create note mutation');
    final uri = Uri.parse('$apiUrl/notes');

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(arg.toMap()),
    );

    if (response.statusCode != 200) throw Error();
  },
);

const apiUrl = 'http://localhost:4001';
