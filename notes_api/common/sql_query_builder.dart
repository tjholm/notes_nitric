import 'package:postgres/postgres.dart';

class SQLQueryBuilder {
  final StringBuffer _query = StringBuffer();
  final Map<String, dynamic> _params = {};
  int _paramIndex = 1;

  // SELECT clause
  SQLQueryBuilder select(List<String> columns) {
    _query.write('SELECT ${columns.join(', ')} ');
    return this;
  }

  // FROM clause
  SQLQueryBuilder from(String table) {
    _query.write('FROM $table ');
    return this;
  }

  // JOIN clause (General method, used by other join types)
  SQLQueryBuilder _join(String joinType, String table, String condition) {
    _query.write('$joinType $table ON $condition ');
    return this;
  }

  // INNER JOIN clause
  SQLQueryBuilder innerJoin(String table, String condition) {
    return _join('INNER JOIN', table, condition);
  }

  // LEFT JOIN clause
  SQLQueryBuilder leftJoin(String table, String condition) {
    return _join('LEFT JOIN', table, condition);
  }

  // RIGHT JOIN clause
  SQLQueryBuilder rightJoin(String table, String condition) {
    return _join('RIGHT JOIN', table, condition);
  }

  // FULL JOIN clause
  SQLQueryBuilder fullJoin(String table, String condition) {
    return _join('FULL JOIN', table, condition);
  }

  // WHERE clause
  SQLQueryBuilder where(String condition, dynamic value) {
    final paramKey = '@p$_paramIndex';
    _params[paramKey] = value;
    _paramIndex++;
    _query.write('WHERE $condition $paramKey ');
    return this;
  }

  // AND clause
  SQLQueryBuilder andWhere(String condition, dynamic value) {
    final paramKey = '@p$_paramIndex';
    _params[paramKey] = value;
    _paramIndex++;
    _query.write('AND $condition $paramKey ');
    return this;
  }

  // OR clause
  SQLQueryBuilder orWhere(String condition, dynamic value) {
    final paramKey = '@p$_paramIndex';
    _params[paramKey] = value;
    _paramIndex++;
    _query.write('OR $condition $paramKey ');
    return this;
  }

  // INSERT clause
  SQLQueryBuilder insert(String table, Map<String, dynamic> values) {
    final columns = values.keys.join(', ');
    final paramKeys = values.keys.map((key) {
      final paramKey = '@p$_paramIndex';
      _params[paramKey] = values[key];
      _paramIndex++;
      return paramKey;
    }).join(', ');

    _query.write(
        'INSERT INTO $table ($columns) VALUES ($paramKeys) RETURNING * ');

    return this;
  }

  // UPDATE clause
  SQLQueryBuilder update(String table, Map<String, dynamic> values) {
    final updateValues = values.entries.map((entry) {
      final paramKey = '@p$_paramIndex';
      _params[paramKey] = entry.value;
      _paramIndex++;
      return '${entry.key} = $paramKey';
    }).join(', ');

    _query.write('UPDATE $table SET $updateValues ');
    return this;
  }

  // DELETE clause
  SQLQueryBuilder deleteFrom(String table) {
    _query.write('DELETE FROM $table ');
    return this;
  }

  // ORDER BY clause
  SQLQueryBuilder orderBy(List<String> columns, {bool ascending = true}) {
    final orderDirection = ascending ? 'ASC' : 'DESC';
    _query.write('ORDER BY ${columns.join(', ')} $orderDirection ');
    return this;
  }

  // UPSERT clause (Insert with ON CONFLICT)
  SQLQueryBuilder upsert(String table, Map<String, dynamic> values,
      List<String> conflictColumns, Map<String, dynamic> updateValues) {
    // Insert part of the query
    final columns = values.keys.join(', ');
    final paramKeys = values.keys.map((key) {
      final paramKey = '@p$_paramIndex';
      _params[paramKey] = values[key];
      _paramIndex++;
      return paramKey;
    }).join(', ');

    _query.write('INSERT INTO $table ($columns) VALUES ($paramKeys) ');

    // ON CONFLICT part of the query (support for multiple columns)
    final conflictCols = conflictColumns.join(', ');
    _query.write('ON CONFLICT ($conflictCols) DO UPDATE SET ');

    // Update part of the query
    final updatePart = updateValues.entries.map((entry) {
      final paramKey = '@p$_paramIndex';
      _params[paramKey] = entry.value;
      _paramIndex++;
      return '${entry.key} = $paramKey';
    }).join(', ');

    _query.write(updatePart);
    return this;
  }

  // Build the final query
  String build() {
    return _query.toString().trim();
  }

  // Execute the query using the provided Connection and Sql.named
  Future<Result> execute(Connection connection) async {
    final query = build();

    // Remove "@" from the keys of the _params map
    final sanitizedParams = _params.map((key, value) {
      return MapEntry(key.replaceFirst('@', ''), value);
    });

    return await connection.execute(
      Sql.named(
        query,
      ),
      parameters: sanitizedParams,
    );
  }

  // Transaction Support

  // Start a transaction using runTx
  Future<void> transaction(Connection connection,
      Future<void> Function(SQLQueryBuilder) action) async {
    await connection.runTx((ctx) async {
      final queryBuilder = SQLQueryBuilder();
      await action(queryBuilder);
    });
  }
}
