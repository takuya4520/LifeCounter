import 'package:flutter/material.dart';
import 'package:life_counter/objectbox.g.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'life_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: LifeCounterPage(),
    );
  }
}

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({Key? key}) : super(key: key);

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];
  bool deleteMode = false;

  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    fetchLifeEvent();
  }

  void fetchLifeEvent() {
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '人生カウンター',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: lifeEvents.length,
        itemBuilder: (context, index) {
          final lifeEvent = lifeEvents[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lifeEvent.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${lifeEvent.count}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50), //角の丸み
                  ),
                  child: IconButton(
                    onPressed: () {
                      lifeEvent.count++;
                      lifeEventBox?.put(lifeEvent);
                      fetchLifeEvent();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50), //角の丸み
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (lifeEvent.count > 0) {
                        lifeEvent.count--;
                        lifeEventBox?.put(lifeEvent);
                        fetchLifeEvent();
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                ),
                if (deleteMode == true)
                  IconButton(
                    onPressed: () {
                      lifeEventBox?.remove(lifeEvent.id);
                      fetchLifeEvent();
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.share,
        backgroundColor: Colors.grey,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: '追加',
            backgroundColor: Colors.grey,
            onTap: () async {
              final newLifeEvent = await Navigator.of(context).push<LifeEvent>(
                MaterialPageRoute(
                  builder: (context) {
                    return const AddLifeEventPage();
                  },
                ),
              );
              if (newLifeEvent != null) {
                lifeEventBox?.put(newLifeEvent);
                fetchLifeEvent();
              }
            },
          ),
          if (deleteMode == false)
            SpeedDialChild(
              child: Icon(Icons.delete_outline),
              label: '削除モード',
              backgroundColor: Colors.grey,
              onTap: () {
                deleteMode = true;
                fetchLifeEvent();
              },
            )
          else if (deleteMode == true)
            SpeedDialChild(
              child: Icon(Icons.delete_outline),
              label: '削除モード終了',
              backgroundColor: Colors.grey,
              onTap: () {
                deleteMode = false;
                fetchLifeEvent();
              },
            ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: '全削除',
            backgroundColor: Colors.grey,
            onTap: () {
              lifeEventBox?.removeAll();
              fetchLifeEvent();
            },
          ),
        ],
      ),
    );
  }
}

class AddLifeEventPage extends StatefulWidget {
  const AddLifeEventPage({Key? key}) : super(key: key);

  @override
  State<AddLifeEventPage> createState() => _AddLifeEventPageState();
}

class _AddLifeEventPageState extends State<AddLifeEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ライフイベント追加ページ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: TextFormField(
        decoration: InputDecoration(
          hintText: 'ここに入力してね',
        ),
        onFieldSubmitted: (text) {
          final lifeEvent = LifeEvent(
            count: 0,
            title: text,
          );
          Navigator.of(context).pop(lifeEvent);
        },
      ),
    );
  }
}
