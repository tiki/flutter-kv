import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_kv/tiki_kv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Database database = await open("password");
  TikiKv kv = TikiKv(database: database);

  await kv.init();

  runApp(MyApp(kv));
}

Future<Database> open(String password) async {
  String dbName = 'tiki_app.db';
  String databasePath = await getDatabasesPath() + '/' + dbName;
  await deleteDatabase(databasePath);
  return await openDatabase(databasePath, password: password);
}

class MyApp extends StatefulWidget {

  TikiKv _kv;

  final keyController = TextEditingController();
  final valueController = TextEditingController();

  MyApp(this._kv, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  String? _error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("TIKI KV Example App "),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Key',
                ),
                controller: widget.keyController,
              ),

              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Value',
                ),
                controller: widget.valueController,
              ),

              OutlinedButton(
                child: new Text("Insert"),
                onPressed: () {

                  widget._kv.create(widget.keyController.value.text, widget.valueController.value.text).catchError((e){
                    setState(() {
                      _error = "Error 2: " + e.toString();
                    });
                  });

                  setState(() {});

                },
              ),

              OutlinedButton(
                child: Text("Upsert"),
                onPressed: () => {
                  widget._kv.upsert(widget.keyController.value.text, widget.valueController.value.text),
                  setState(() {
                    _error = null;
                  })
                },
              ),

              OutlinedButton(
                child: Text("Delete"),
                onPressed: () => {
                  widget._kv.delete(widget.keyController.value.text),
                  setState(() {
                    _error = null;
                  })
                },
              ),

              OutlinedButton(
                child: Text("DeleteAll"),
                onPressed: () => {
                  widget._kv.deleteAll(),
                  setState(() {
                    _error = null;
                  })
                },
              ),

              OutlinedButton(
                child: Text("Refresh"),
                onPressed: () => setState(() {
                  _error = null;
                }),
              ),

              Text(_error == null ? "No Error" : _error!!),

              // if (_error != null) ...[
              //   Text(_error!)
              // ] else ...[
              //
              // ],



            FutureBuilder(
                future: widget._kv.read(widget.keyController.value.text),
                initialData: "Loading text..",
                builder: (BuildContext context, AsyncSnapshot<String?> text) {
                  return Text(
                        (text.data == null ? "Data: Not Found" : "Data: " + text.data!!)
                  );
                })

            ],
          )
        ),
      ),
    );
  }

}
