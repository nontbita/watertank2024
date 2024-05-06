import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

String distance = '';
String time = '';
String roundedDistance = '';
int extractedKeyNumber = 0;
//String currentDate = "xx";
final  distancesFive = <String>[];
final  timesFive = <String>[];
final  displayFive = <String>[];
//final  displayFive = ["1","2","3","4","5"];


void main() async {
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

  /*
  final database = FirebaseDatabase.instance;
  final dataRef = database.ref('watertank2');
  final snapshot = await dataRef.get();
  for (final child in snapshot.children) {
    if (child.key!.startsWith('time')) {
      final timeValue = child.value as String;
      final currentDate = getCurrentDate(timeValue);
      print("First Current Date = "+currentDate);
    }
  }
  */

  //getDistanceAndTimeData(currentDate);
  runApp(const MyApp());
  await getDistanceAndTimeData();
}

class MyApp extends StatelessWidget {
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Tank 6FL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Water Tank 6FL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
      final data = event.snapshot.value as Map<String, dynamic>;

      for (final key in data.keys) {
        if (key.startsWith('distance')) {
          final lastThreeDigits = key.substring(key.length - 3);
          extractedKeyNumber = int.parse(lastThreeDigits);
          final distanceValue = data[key] as double;
          distance = distanceValue.toString();
          roundedDistance = double.parse(distance).toStringAsFixed(1);
          distance = roundedDistance;
          print(roundedDistance);
          //print(distance.runtimeType);
        } else if (key.startsWith('time')) {
          final timeValue = data[key];
          time = timeValue;
          print(time);
          //print(time.runtimeType);
        } else {
          // Handle keys that don't start with "distance" or "time"
          print("Unrecognized key: $key");
        }

        setState(() => distance = roundedDistance);
        getDistanceAndTimeData();
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
            const Text('Water Level:'),
            SizedBox(height: 16.0), // Add a blank space of 16 pixels
            Text(
              distance,
              //_data != null ? _data : 'No data available',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16.0), // Add a blank space of 16 pixels
            Text(
              time,
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            SizedBox(height: 32.0), // Add a blank space of 16 pixels
            ElevatedButton(
              onPressed: () async {
                setState(() => distance = roundedDistance);
              },
              child: Text("History"),
            ),
            SizedBox(height: 16.0), // Add a blank space of 16 pixels
            for (final text in displayFive)
              Text(text + " cm",style: TextStyle(fontSize: 14.0, color: Colors.grey)), // Customize this to your needs
          ],
        ),
      ),
    );
  }
}

Future<String?> getCurrentDate() async {
  final database = FirebaseDatabase.instance;
  final dataRef = database.ref('watertank2');
  final snapshot = await dataRef.get();

  String? currentDate; // Declare currentDate outside the loop

  for (final child in snapshot.children) {
    if (child.key!.startsWith('time')) {
      final timeValue = child.value as String;
      currentDate = await getCurrentDateFromTimeValue(timeValue);
      print("Final Current Date = "+currentDate);
    }
  }
  return currentDate;
}

Future<void> getDistanceAndTimeData() async {
  // Get a reference to the "watertank1" node
  final database = FirebaseDatabase.instance;
  final dataRef = database.ref('watertank1');
  final currentDate = await getCurrentDate();
  if (currentDate != null) {
    print("Current Date = " + currentDate);
  } else {
    print("Current date is not available.");
  }

  // Create an empty list to store the distance data
  final distances = <double>[];
  final times = <String>[];
  print("EMPTY LIST CREATED");

  // Get all children under the "watertank1" node
  final snapshot = await dataRef.get();
  print("SNAPSHOT CREATED");

  // Loop through each child and extract the distance value
  for (final child in snapshot.children) {
    if (child.key!.startsWith('distance')) {
      final distanceValue = child.value as double;
      distances.add(distanceValue);
    }
  }

  print("FOR LOOPS 1 COMPLETED");

  // Loop through each child and extract the time value
  for (final child in snapshot.children) {
    if (child.key!.startsWith('time')) {
      final timeValue = child.value as String;
      times.add(timeValue);
    }
  }

  print("FOR LOOPS 2 COMPLETED");

  distancesFive.clear();
  timesFive.clear();
  print("DATA CLEARED");
  for (int i = 0; i < 25; i++) {
    int interval = 5; // minutes
    int dataLocation = extractedKeyNumber - interval * (i+1);
    if (dataLocation < 0) dataLocation = dataLocation + 1000;
    print("+1000");
    print(getCurrentDateFromTimeValue(times[dataLocation]));
    if (currentDate != null) {
      print("Current Date = " + currentDate);
    } else {
      print("Current date is not available.");
    }
    String stringCurrentDate = "20";//currentDate.toString();
    if (getCurrentDateFromTimeValue(times[dataLocation]) == stringCurrentDate) {
      distancesFive.add(distances[dataLocation].toStringAsFixed(1));
      timesFive.add(times[dataLocation]);
      print(i);
    }
  }

  print("Current Key Number = "+extractedKeyNumber.toString());
  displayFive.clear();
  print("DISPLAY FIVE CLEARED");
  for (int i = 0; i < 25; i++) {
    displayFive.add(timesFive[i] + "      " + distancesFive[i]);
    print(i);
  }
  //print(timesFive);

  // Return the list of distance values
  //return timesFive;
}

String getCurrentDateFromTimeValue(String date_time_string) {
  // Find the index of the first space
  int space_index = date_time_string.indexOf(" ");

  // Separate the date and time parts
  String date_part = date_time_string.substring(0, space_index);
  String time_part = date_time_string.substring(space_index + 1);

  // Separate date components with "-"
  List<String> date_components = date_part.split("-");
  String separated_date = date_components.join("-");

  // Return the separated date and time as a single string
  return date_components[2];
}




