import 'package:flutter/material.dart';
import '../models/car_model.dart';
import 'payment_screen.dart';

class CityToCityCarBookingScreen extends StatefulWidget {
  @override
  State<CityToCityCarBookingScreen> createState() => _CityToCityCarBookingScreenState();
}

class _CityToCityCarBookingScreenState extends State<CityToCityCarBookingScreen> {
  String? _selectedPickupCity;
  String? _selectedDropoffCity;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  int _totalDays = 1;
  Car? _selectedCar;

  final List<String> _pakistanCities = [
    'Islamabad', 'Rawalpindi', 'Lahore', 'Karachi', 'Peshawar',
    'Quetta', 'Faisalabad', 'Multan', 'Hyderabad', 'Gujranwala',
    'Sialkot', 'Bahawalpur', 'Sargodha', 'Sukkur', 'Larkana',
    'Sheikhupura', 'Jhang', 'Rahim Yar Khan', 'Gujrat', 'Mardan',
    'Kasur', 'Dera Ghazi Khan', 'Sahiwal', 'Nawabshah', 'Mirpur Khas',
    'Okara', 'Mingora', 'Chiniot', 'Kamoke', 'Hafizabad',
    'Attock', 'Muridke', 'Bhimber', 'Kotli', 'Rawalakot',
    'Gilgit', 'Skardu', 'Chitral', 'Abbottabad', 'Mansehra',
    'Swat', 'Naran', 'Kaghan', 'Hunza', 'Fairy Meadows'
  ];

  final List<Car> _availableCars = [
    Car(
      id: '1',
      name: 'Toyota Corolla',
      type: 'Sedan',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Toyota_Corolla_Limousine_Monrepos_2019_IMG_1908.jpg/400px-Toyota_Corolla_Limousine_Monrepos_2019_IMG_1908.jpg',
      pricePerKm: 25,
      capacity: 4,
      features: ['AC', 'Music System', 'Comfortable Seats', 'Fuel Efficient'],
      rating: 4.5,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      ac: true,
    ),
    Car(
      id: '2',
      name: 'Honda Civic',
      type: 'Sedan',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/2022_Honda_Civic_Touring_in_Lunar_Silver_Metallic%2C_Front_Left%2C_05-10-2022.jpg/400px-2022_Honda_Civic_Touring_in_Lunar_Silver_Metallic%2C_Front_Left%2C_05-10-2022.jpg',
      pricePerKm: 28,
      capacity: 4,
      features: ['AC', 'Premium Sound', 'Leather Seats', 'Sunroof'],
      rating: 4.7,
      transmission: 'Automatic',
      fuelType: 'Petrol',
      ac: true,
    ),
    Car(
      id: '3',
      name: 'Toyota Hiace',
      type: 'Van',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/2020_Toyota_HiAce_%28front%29.jpg/400px-2020_Toyota_HiAce_%28front%29.jpg',
      pricePerKm: 35,
      capacity: 12,
      features: ['AC', 'Spacious', 'Luggage Space', 'Comfortable'],
      rating: 4.3,
      transmission: 'Manual',
      fuelType: 'Diesel',
      ac: true,
    ),
    Car(
      id: '4',
      name: 'Suzuki Mehran',
      type: 'Hatchback',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Mehran_Model_2001_Right_Side_View_At_Lowari_Pass%2CChitral%2CKPK.jpg/400px-Mehran_Model_2001_Right_Side_View_At_Lowari_Pass%2CChitral%2CKPK.jpg',
      pricePerKm: 15,
      capacity: 4,
      features: ['Economical', 'Easy Parking', 'Fuel Efficient', 'Low Maintenance'],
      rating: 4.0,
      transmission: 'Manual',
      fuelType: 'Petrol',
      ac: false,
    ),
    Car(
      id: '5',
      name: 'Toyota Fortuner',
      type: 'SUV',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/2015_Toyota_Fortuner_%28New_Zealand%29.jpg/400px-2015_Toyota_Fortuner_%28New_Zealand%29.jpg',
      pricePerKm: 40,
      capacity: 7,
      features: ['AC', '4x4', 'Luxury', 'Off-road', 'Spacious'],
      rating: 4.6,
      transmission: 'Automatic',
      fuelType: 'Diesel',
      ac: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City to City Car Booking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup City
            _buildCityDropdown('Pickup City', _selectedPickupCity, (value) {
              setState(() {
                _selectedPickupCity = value;
              });
            }),

            SizedBox(height: 16),

            // Dropoff City
            _buildCityDropdown('Dropoff City', _selectedDropoffCity, (value) {
              setState(() {
                _selectedDropoffCity = value;
              });
            }),

            SizedBox(height: 16),

            // Pickup Date
            _buildDatePicker(),

            SizedBox(height: 16),

            // Pickup Time
            _buildTimePicker(),

            SizedBox(height: 16),

            // Total Days
            _buildDaysSelector(),

            SizedBox(height: 24),

            // Available Cars
            if (_selectedPickupCity != null && _selectedDropoffCity != null)
              _buildAvailableCars(),

            SizedBox(height: 20),

            // Book Now Button
            if (_selectedCar != null)
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookCar,
                  child: Text('Book Car - Rs. ${_calculateTotalAmount().toStringAsFixed(0)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown(String label, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            hint: Text('Select $label'),
            items: _pakistanCities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _pickupDate != null
                      ? '${_pickupDate!.day}/${_pickupDate!.month}/${_pickupDate!.year}'
                      : 'Select Pickup Date',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: _selectPickupDate,
                child: Text('Choose Date'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _pickupTime != null
                      ? '${_pickupTime!.hour}:${_pickupTime!.minute.toString().padLeft(2, '0')}'
                      : 'Select Pickup Time',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: _selectPickupTime,
                child: Text('Choose Time'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Days: $_totalDays',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_totalDays > 1) {
                  setState(() {
                    _totalDays--;
                  });
                }
              },
              icon: Icon(Icons.remove),
            ),
            Expanded(
              child: Slider(
                value: _totalDays.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (value) {
                  setState(() {
                    _totalDays = value.toInt();
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                if (_totalDays < 30) {
                  setState(() {
                    _totalDays++;
                  });
                }
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableCars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Cars',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ..._availableCars.map((car) => _buildCarCard(car)),
      ],
    );
  }

  Widget _buildCarCard(Car car) {
    bool isSelected = _selectedCar?.id == car.id;
    double estimatedDistance = _calculateDistance();
    double totalAmount = car.pricePerKm * estimatedDistance * _totalDays;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: ListTile(
        leading: Image.network(
          car.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: Icon(Icons.directions_car, color: Colors.grey),
            );
          },
        ),
        title: Text(
          car.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${car.type} • ${car.transmission} • ${car.fuelType}'),
            Text('Capacity: ${car.capacity} people'),
            Text('Features: ${car.features.join(', ')}'),
            SizedBox(height: 4),
            Text(
              'Rs. ${totalAmount.toStringAsFixed(0)} for $_totalDays days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            Text(car.rating.toString()),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedCar = car;
          });
        },
      ),
    );
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  Future<void> _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  double _calculateDistance() {
    // Simple distance calculation based on cities
    Map<String, double> cityDistances = {
      'Islamabad-Rawalpindi': 20,
      'Islamabad-Lahore': 380,
      'Islamabad-Karachi': 1500,
      'Lahore-Karachi': 1200,
      'Rawalpindi-Lahore': 370,
      'Islamabad-Peshawar': 180,
      'Lahore-Faisalabad': 130,
      'Karachi-Hyderabad': 160,
      'Islamabad-Multan': 470,
      'Lahore-Multan': 320,
    };

    String key = '${_selectedPickupCity}-${_selectedDropoffCity}';
    String reverseKey = '${_selectedDropoffCity}-${_selectedPickupCity}';

    return cityDistances[key] ?? cityDistances[reverseKey] ?? 100;
  }

  double _calculateTotalAmount() {
    if (_selectedCar == null) return 0;
    double distance = _calculateDistance();
    return _selectedCar!.pricePerKm * distance * _totalDays;
  }

  // ✅ FIXED: _bookCar method with correct PaymentScreen constructor
  void _bookCar() {
    if (_selectedCar == null || _pickupDate == null || _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Calculate total amount
    double totalAmount = _calculateTotalAmount();

    // Prepare booking details for payment screen
    Map<String, dynamic> bookingDetails = {
      'carName': _selectedCar!.name,
      'carType': _selectedCar!.type,
      'pickupCity': _selectedPickupCity!,
      'dropoffCity': _selectedDropoffCity!,
      'pickupDate': '${_pickupDate!.day}/${_pickupDate!.month}/${_pickupDate!.year}',
      'pickupTime': '${_pickupTime!.hour}:${_pickupTime!.minute.toString().padLeft(2, '0')}',
      'totalDays': _totalDays,
      'totalDistance': _calculateDistance().toStringAsFixed(0),
      'transmission': _selectedCar!.transmission,
      'fuelType': _selectedCar!.fuelType,
      'capacity': _selectedCar!.capacity,
      'totalAmount': totalAmount,
    };

    // Navigate to Payment Screen - WITH CORRECT CONSTRUCTOR
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingType: 'car',
          bookingData: bookingDetails,
        ),
      ),
    );
  }

}