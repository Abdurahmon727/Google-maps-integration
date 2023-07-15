import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_example/const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer mapCompleter = Completer();
  LatLng? location;
  int mapTypeIndex = 0;
  bool showTraffic = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: location == null
          ? const Center(child: Text('Loading'))
          : Stack(
              alignment: Alignment.topRight,
              children: [
                GoogleMap(
                  onMapCreated: (controller) =>
                      mapCompleter.complete(controller),
                  mapType: mapTypes[mapTypeIndex % 4],
                  zoomControlsEnabled: false,
                  trafficEnabled: showTraffic,
                  myLocationEnabled: true,
                  markers: {
                    Marker(
                        markerId: const MarkerId('location'),
                        position: location!),
                  },
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(41.01, 71.66), zoom: 10),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      FloatingActionButton(
                        child: const Icon(Icons.location_on),
                        onPressed: () async {
                          final pos = await Geolocator.getCurrentPosition();
                          location = LatLng(pos.latitude, pos.longitude);
                          setState(() {});
                          final GoogleMapController contr =
                              await mapCompleter.future;
                          contr
                              .animateCamera(CameraUpdate.newLatLng(location!));
                        },
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        child: const Icon(Icons.location_city),
                        onPressed: () {
                          mapTypeIndex++;

                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        child: const Icon(Icons.traffic),
                        onPressed: () {
                          showTraffic = !showTraffic;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    final pos = await Geolocator.getCurrentPosition();
    location = LatLng(pos.latitude, pos.longitude);
    setState(() {});
  }
}
