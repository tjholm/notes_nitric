import 'package:nitric_sdk/nitric.dart';

import '../common/sql_query_builder.dart';
import '../models/note.dart';
import '../resources/db.dart';

void main() async {
  final connection = await getConnection();

  final helloApi = Nitric.api("main");

  helloApi.get("/notes", (ctx) async {
    final query = SQLQueryBuilder()
      ..select(['id', 'title', 'content'])
      ..from('notes');

    final rows = await query.execute(connection);

    final notes = rows.map((row) => Note.fromMap(row.toColumnMap())).toList();

    ctx.res.json({'notes': notes.map((note) => note.toMap()).toList()});

    return ctx;
  });

  helloApi.post("/notes", (ctx) async {
    final newNote = CreateNoteBody.fromMap(ctx.req.json());

    final query = SQLQueryBuilder()..insert('notes', newNote.toMap());
    final rows = await query.execute(connection);

    final notes = rows.map((row) => Note.fromMap(row.toColumnMap())).toList();

    ctx.res.json({'notes': notes.map((note) => note.toMap()).toList()});

    return ctx;
  });

  helloApi.put("/notes/:id", (ctx) async {
    final idArg = ctx.req.pathParams["id"]!;
    final id = int.tryParse(idArg);

    if (id == null) {
      ctx.res.status = 400;
      return ctx;
    }

    final updatedNote = UpdateNoteBody.fromMap(ctx.req.json());

    final updateQuery = SQLQueryBuilder()
      ..update('notes', updatedNote.toMap())
      ..where('id = ', id);
    await updateQuery.execute(connection);

    final selectQuery = SQLQueryBuilder()
      ..select(['id', 'title', 'content'])
      ..from('notes')
      ..where('id =', id);

    final rows = await selectQuery.execute(connection);

    final notes = rows.map((row) => Note.fromMap(row.toColumnMap())).toList();

    ctx.res.json({'notes': notes.map((note) => note.toMap()).toList()});

    return ctx;
  });

  helloApi.delete("/notes/:id", (ctx) async {
    final idArg = ctx.req.pathParams["id"]!;
    final id = int.tryParse(idArg);

    if (id == null) {
      ctx.res.status = 400;
      return ctx;
    }

    final query = SQLQueryBuilder()
      ..deleteFrom('notes')
      ..where('id =', id);
    await query.execute(connection);

    ctx.res.status = 204;

    return ctx;
  });
}
