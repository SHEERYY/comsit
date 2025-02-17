import 'package:comsit/newsfeed/SearchScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'creatcarpoolpostscreen.dart';

// Carpool Ride Model
class CarpoolRide {
  final String id;
  final String driverName;  // Driver's name
  final String pickupLocation;
  final String classStartTime;
  final String classEndTime;
  final int daysToUniversity;
  final int availableSeats;
  final File? timetableImage;
  final String route;  // Add route information

  CarpoolRide({
    required this.id,
    required this.driverName,  // Add driverName to constructor
    required this.pickupLocation,
    required this.classStartTime,
    required this.classEndTime,
    required this.daysToUniversity,
    required this.availableSeats,
    this.timetableImage,
    required this.route,  // Add route parameter
  });
}

// Carpool Feed Screen with Post Adding Logic
class CarpoolFeedScreen extends StatefulWidget {
  @override
  _CarpoolFeedScreenState createState() => _CarpoolFeedScreenState();
}

class _CarpoolFeedScreenState extends State<CarpoolFeedScreen> {
  final List<CarpoolRide> _rides = [];

  void _addRide(CarpoolRide ride) {
    setState(() {
      _rides.add(ride);
    });
  }

  void _navigateToCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCarpoolPostScreen(
          onPostCreated: (post) {
            // Ensure the 'route' is passed correctly
            final newRide = CarpoolRide(
              id: DateTime.now().toString(),
              driverName: post['driverName'],  // Pass driverName
              pickupLocation: post['pickupLocation'],
              classStartTime: post['classStartTime'],
              classEndTime: post['classEndTime'],
              daysToUniversity: post['daysToUniversity'],
              availableSeats: post['availableSeats'],
              timetableImage: post['timetableImage'],
              route: post['selectedRoute'],  // Correctly passing 'route' here
            );
            _addRide(newRide);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carpool Rides',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Post Button
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: Colors.blue.shade800,
            onPressed: _navigateToCreatePost,
            tooltip: 'Post Ride',
          ),
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.blue.shade800,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: _rides.isEmpty
          ? Center(
              child: Text(
                'No carpool posts available. Post a ride!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _rides.length,
              itemBuilder: (ctx, index) {
                final ride = _rides[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  elevation: 4,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Image if available
                      if (ride.timetableImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.file(
                            ride.timetableImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade800,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),

                      // Post Details
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Driver Name and Route
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver: ${ride.driverName}',  // Display driver's name
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),  // Space between driver name and route
                                Text(
                                  'Route: ${ride.route}',  // Display route
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            // Pickup Location
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Drivers Loction: ${ride.pickupLocation}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(Icons.location_on, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                              ],
                            ),
                            Divider(height: 16, thickness: 1),

                            // Class Timings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Class Time:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  '${ride.classStartTime} - ${ride.classEndTime}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Days and Seats Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'University Days: ${ride.daysToUniversity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Available Seats: ${ride.availableSeats}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom Actions
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Messaging is not implemented yet'),
                                ),
                              );
                            },
                            child: Text(
                              'Message Driver',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
