// screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // Pakistan ke tourist spots ke locations
  final List<Map<String, dynamic>> _touristSpots = [
    {
      'id': '1',
      'name': 'Hunza Valley',
      'lat': 36.3167,
      'lng': 74.6500,
      'type': 'valley',
      'description': 'Gilgit-Baltistan ka khoobsurat valley',
    },
    {
      'id': '2',
      'name': 'Skardu',
      'lat': 35.2971,
      'lng': 75.6333,
      'type': 'city',
      'description': 'Duniya ki sab se unchay peaks ka gateway',
    },
    {
      'id': '3',
      'name': 'Fairy Meadows',
      'lat': 35.4214,
      'lng': 74.5969,
      'type': 'meadow',
      'description': 'Nanga Parbat ka nazara - Jannat on Earth',
    },
    {
      'id': '4',
      'name': 'Swat Valley',
      'lat': 35.2220,
      'lng': 72.4258,
      'type': 'valley',
      'description': 'Pakistan ka Switzerland',
    },
    {
      'id': '5',
      'name': 'Naran Kaghan',
      'lat': 34.9100,
      'lng': 73.6500,
      'type': 'valley',
      'description': 'KPK ka khoobsurat valley',
    },
    {
      'id': '6',
      'name': 'Murree',
      'lat': 33.9072,
      'lng': 73.3903,
      'type': 'hill_station',
      'description': 'Islamabad ke qareeb hill station',
    },
    {
      'id': '7',
      'name': 'Islamabad',
      'lat': 33.6844,
      'lng': 73.0479,
      'type': 'city',
      'description': 'Pakistan ki capital',
    },
    {
      'id': '8',
      'name': 'Lahore',
      'lat': 31.5497,
      'lng': 74.3436,
      'type': 'city',
      'description': 'Pakistan ka cultural center',
    },
    {
      'id': '9',
      'name': 'Karachi',
      'lat': 24.8607,
      'lng': 67.0011,
      'type': 'city',
      'description': 'Pakistan ka economic hub',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      // Location permission check karein
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Current location get karein
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _addMarkers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkers() {
    Set<Marker> markers = {};

    // Current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Aapki Location',
            snippet: 'Yahan hain aap',
          ),
        ),
      );
    }

    // Tourist spots ke markers
    for (var spot in _touristSpots) {
      markers.add(
        Marker(
          markerId: MarkerId(spot['id']),
          position: LatLng(spot['lat'], spot['lng']),
          icon: _getMarkerIcon(spot['type']),
          infoWindow: InfoWindow(
            title: spot['name'],
            snippet: spot['description'],
          ),
          onTap: () {
            _showSpotDetails(spot);
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'valley':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'city':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'meadow':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'hill_station':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _showSpotDetails(Map<String, dynamic> spot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spot['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(spot['description']),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Latitude: ${spot['lat']}, Longitude: ${spot['lng']}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToLocation(spot['lat'], spot['lng']);
                    },
                    child: Text('Map Par Dekhein'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Band Karein'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToLocation(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        12.0,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem('🟢 Valley', 'Hunza, Swat, Naran'),
            _buildLegendItem('🔴 City', 'Islamabad, Lahore, Karachi'),
            _buildLegendItem('🟠 Meadow', 'Fairy Meadows'),
            _buildLegendItem('🟣 Hill Station', 'Murree'),
            _buildLegendItem('🔵 Aapki Location', 'Current Location'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Theek Hai'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String color, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(color, style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pakistan Travel Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _currentPosition != null
                ? () {
              _goToLocation(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              );
            }
                : null,
            tooltip: 'Aapki Location Par Jaen',
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showLegend,
            tooltip: 'Map Legend',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Map Load Ho Raha Hai...'),
            SizedBox(height: 10),
            Text('Zara Intezar Karein'),
          ],
        ),
      )
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : LatLng(30.3753, 69.3451), // Pakistan center
          zoom: 6.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton(
        onPressed: () {
          _goToLocation(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        },
        child: Icon(Icons.my_location),
        tooltip: 'Aapki Location Par Jaen',
      )
          : null,
    );
  }
}