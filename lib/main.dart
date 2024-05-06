import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'current_time_widget.dart';
import 'data_utils.dart';

/*
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are ready
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}
 */

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const options = FirebaseOptions(
      apiKey: "AIzaSyC6i6O-FS-luxlGk3_xYyLQeyRXMKHptuk",
      authDomain: "watertank2-3abb1.firebaseapp.com",
      databaseURL: "https://watertank2-3abb1-default-rtdb.firebaseio.com",
      projectId: "watertank2-3abb1",
      storageBucket: "watertank2-3abb1.appspot.com",
      messagingSenderId: "801002382143",
      appId: "1:801002382143:web:c0747be3b8a45b1781e98a",
      measurementId: "G-G8WX1X6JPV"
  );
  await Firebase.initializeApp(options: options);

  runApp(const MyApp());
  await getDistanceAndTimeData();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tank 2024 (Q2)',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Water Tank (6FL)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    final dataRef = database.ref('watertank2');
    dataRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<Object?, Object?>;
      final castedData = data.cast<String, dynamic>();

      for (final key in castedData.keys) {
        if (key.startsWith('distance')) {
          final lastThreeDigits = key.substring(key.length - 3);
          extractedKeyNumber = int.parse(lastThreeDigits);
          final distanceValue = castedData[key] as double;
          distance = distanceValue.toString();
          roundedDistance = double.parse(distance).toStringAsFixed(1);
          distance = roundedDistance;
          print("Current Level: $roundedDistance");
          //print(distance.runtimeType);
        } else if (key.startsWith('time')) {
          final timeValue = castedData[key];
          time = timeValue;
          print(time);
          //print(time.runtimeType);
        } else {
          // Handle keys that don't start with "distance" or "time"
          print("Unrecognized key: $key");
        }

        setState(() => distance = roundedDistance);
        //getDistanceAndTimeData();
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Water Level (cm)'),
            SizedBox(height: 16.0),
            Text(
              distance,
              //_data != null ? _data : 'No data available',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              "at $time",
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            const CurrentTimeWidget(),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                setState(() => distance = roundedDistance);
              },
              child: Text("History"),
            ),
            SizedBox(height: 16.0), // Add a blank space of 16 pixels
            for (final text in displayFive)
              Text(text + " cm",style: TextStyle(fontSize: 14.0, color: Colors.grey)),
          ], // children
        ),
      ),
    );
  }
}