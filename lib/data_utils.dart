import 'package:firebase_database/firebase_database.dart';

////////////// PREVIOUS CODES ///////////////
/////////////////////////////////////////////

String distance = '';
String time = '';
String roundedDistance = '';
int extractedKeyNumber = 0;
//String currentDate = "xx";
final  distancesFive = <String>[];
final  timesFive = <String>[];
final  displayFive = <String>[];
//final  displayFive = ["1","2","3","4","5"];

Future<String?> getCurrentDate() async {
  final database = FirebaseDatabase.instance;
  final dataRef = database.ref('watertank2');
  final snapshot = await dataRef.get();

  String? currentDate; // Declare currentDate outside the loop

  for (final child in snapshot.children) {
    if (child.key!.startsWith('time')) {
      final timeValue = child.value as String;
      currentDate = await getCurrentDateFromTimeValue(timeValue);
      //print("Final Current Date = "+currentDate);
    }
  }
  return currentDate;
}

Future<void> getDistanceAndTimeData() async {
  // Get a reference to the "watertank1" node
  final database = FirebaseDatabase.instance;
  final dataRef = database.ref('watertank1');
  final currentDate = await getCurrentDate();

  // Create an empty list to store the distance data
  final distances = <double>[];
  final times = <String>[];

  // Get all children under the "watertank1" node
  final snapshot = await dataRef.get();

  // Loop through each child and extract the distance value
  for (final child in snapshot.children) {
    if (child.key!.startsWith('distance')) {
      final distanceValue = child.value as double;
      distances.add(distanceValue);
    }
  }

  // Loop through each child and extract the time value
  for (final child in snapshot.children) {
    if (child.key!.startsWith('time')) {
      final timeValue = child.value as String;
      times.add(timeValue);
    }
  }

  distancesFive.clear();
  timesFive.clear();

  for (int i = 0; i < 25; i++) {
    int interval = 5; // minutes
    int dataLocation = extractedKeyNumber - interval * (i+1);
    if (dataLocation < 0) dataLocation = dataLocation + 1000;
    //print(getCurrentDateFromTimeValue(times[dataLocation]));
    String stringCurrentDate = currentDate.toString();//currentDate.toString();
    if (getCurrentDateFromTimeValue(times[dataLocation]) == stringCurrentDate) {
      distancesFive.add(distances[dataLocation].toStringAsFixed(1));
      timesFive.add(times[dataLocation]);
      //print(i);
    }
  }

  print("Current Key Number = "+extractedKeyNumber.toString());
  displayFive.clear();
  try{
    for (int i = 0; i < 25; i++) {
      displayFive.add(timesFive[i] + "      " + distancesFive[i]);
    }
  } catch (e) {
    if (e is RangeError) {
      print("RangeError caught: ${e.message}");
    } else {
      rethrow;
    }
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
