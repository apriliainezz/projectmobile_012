import 'package:flutter/material.dart';
import 'package:responsiah/models/movie_model.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:responsiah/services/local_notification_service.dart';
import 'package:responsiah/pages/payment_success_page.dart';
import 'package:responsiah/services/session_service.dart';
import 'package:responsiah/database/database_helper.dart';

class RentalPage extends StatefulWidget {
  final Kdrama movie;

  RentalPage({required this.movie});

  @override
  _RentalPageState createState() => _RentalPageState();
}

class _RentalPageState extends State<RentalPage> {
  String? _selectedCountry;
  String? _selectedTimezone;

  final Map<String, List<String>> _countryTimezones = {
    'Indonesia (IDR)': ['WITA', 'WIB', 'WIT'],
    'United States (USD)': ['EST', 'PST'],
    'Euro Zone (EUR)': ['CET', 'CEST'],
    'United Kingdom (GBP)': ['GMT', 'BST'],
    'Japan (JPY)': ['JST'],
  };

  final Map<String, double> _countryPrices = {
    'Indonesia (IDR)': 20000.0,
    'United States (USD)': 1.5,
    'Euro Zone (EUR)': 1.3,
    'United Kingdom (GBP)': 1.2,
    'Japan (JPY)': 150.0,
  };

  List<String> get _timezoneOptions {
    return _countryTimezones[_selectedCountry] ?? [];
  }

  final List<String> _countryOptions = [
    'Indonesia (IDR)',
    'United States (USD)',
    'Euro Zone (EUR)',
    'United Kingdom (GBP)',
    'Japan (JPY)',
  ];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _selectedCountry = 'Indonesia (IDR)'; // Set default country
  }

  String _getTimeWithTimezone() {
    if (_selectedTimezone == null) {
      return DateFormat('yyyy-MM-dd – hh:mm a').format(DateTime.now());
    }

    String timezoneName = 'Asia/Jakarta'; // Default timezone
    switch (_selectedTimezone) {
      case 'WITA':
        timezoneName = 'Asia/Makassar';
        break;
      case 'WIB':
        timezoneName = 'Asia/Jakarta';
        break;
      case 'WIT':
        timezoneName = 'Asia/Jayapura';
        break;
      case 'EST':
        timezoneName = 'America/New_York';
        break;
      case 'PST':
        timezoneName = 'America/Los_Angeles';
        break;
      case 'CET':
        timezoneName = 'Europe/Berlin';
        break;
      case 'CEST':
        timezoneName = 'Europe/Berlin';
        break;
      case 'GMT':
        timezoneName = 'Europe/London';
        break;
      case 'BST':
        timezoneName = 'Europe/London';
        break;
      case 'JST':
        timezoneName = 'Asia/Tokyo';
        break;
    }

    final location = tz.getLocation(timezoneName);
    final now = tz.TZDateTime.now(location);
    final formatter = DateFormat('yyyy-MM-dd – hh:mm a');
    return '${formatter.format(now)} (${location.name})';
  }

  String _getRentalPrice() {
    if (_selectedCountry == null) {
      return 'Rental Price: N/A';
    }
    final price = _countryPrices[_selectedCountry] ?? 0.0;
    final currency = _selectedCountry!
        .split(' ')
        .last
        .replaceAll('(', '')
        .replaceAll(')', '');
    final formattedPrice = NumberFormat('#,##0.00', 'en_US').format(price);
    return 'Rental Price: $formattedPrice $currency';
  }

  Future<void> _showNotification(String title, String body) async {
    await LocalNotificationService.showNotification(
      title: title,
      body: body,
      payload: 'rental_notification',
    );
  }

  Future<void> _processPayment() async {
    if (_selectedCountry == null || _selectedTimezone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select country and timezone first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get current user ID
    final currentUserId = SessionService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save rental data to database
      final price = _countryPrices[_selectedCountry] ?? 0.0;
      final currency = _selectedCountry!
          .split(' ')
          .last
          .replaceAll('(', '')
          .replaceAll(')', '');

      final rental = await DatabaseHelper.rentMovie(
        widget.movie.id.toString(),
        currentUserId,
        price,
        rentalHours: 6, // Set rental duration to 6 hours
        imageUrl: widget.movie.imgUrl ?? '',
        title: widget.movie.title ?? '',
        synopsis: widget.movie.synopsis ?? '',
        genre: widget.movie.genre ?? '',
        currency: currency,
        paymentTime: _getTimeWithTimezone(),
      );

      // Check if rental was successful
      if (rental == null) {
        // Rental already exists for this user and movie
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda sudah menyewa film ini!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show notification for successful payment
      await _showNotification(
        'Payment Successful!',
        'Your payment for "${widget.movie.title}" has been processed successfully.',
      );

      // Navigate to payment success page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            movie: widget.movie,
            totalPayment: price.toString(),
            currency: currency,
            paymentTime: _getTimeWithTimezone(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    String now = _getTimeWithTimezone();
    final rentalPrice = _getRentalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Payment'),
        backgroundColor: Color(0xFFAEDFF7),
      ),
      backgroundColor: Colors.grey[200],
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: viewportConstraints.maxWidth,
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ), // Adjusted padding
                        child: Column(
                          children: [
                            // "Pilih Negara" section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Negara',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton<String>(
                                  isExpanded: true, // Make it full width
                                  value: _selectedCountry,
                                  hint: Text('Select Country'),
                                  items: _countryOptions.map((String country) {
                                    return DropdownMenuItem<String>(
                                      value: country,
                                      child: Text(country),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCountry = newValue;
                                      _selectedTimezone = null;
                                      // Reset timezone when country changes
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // "Pilih Zona Waktu" section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Zona Waktu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton<String>(
                                  isExpanded: true, // Make it full width
                                  value: _selectedTimezone,
                                  hint: Text('Select Timezone'),
                                  items:
                                      _timezoneOptions.map((String timezone) {
                                    return DropdownMenuItem<String>(
                                      value: timezone,
                                      child: Text(timezone),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedTimezone = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mata Uang: ${_selectedCountry ?? "Not Selected"}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      Text(
                        'Zona Waktu: ${_selectedTimezone ?? "Not Selected"}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display current date and time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.blue,
                                    ), // Add clock icon with blue color
                                    SizedBox(width: 8),
                                    Text(
                                      now,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ), // Made it bold
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                // Movie Poster
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        widget.movie.imgUrl ??
                                            'https://via.placeholder.com/300',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  widget.movie.title!,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Year: ${widget.movie.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Genre: ${widget.movie.genre ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Sinopsis',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  widget.movie.synopsis ??
                                      'No description available.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 16),

                                // Payment Method Selection
                                Column(
                                  // Changed Row to Column
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rentalPrice,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Per 6 Hours',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFAEDFF7),
                                              textStyle:
                                                  TextStyle(fontSize: 16),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                            ),
                                            onPressed: _selectedCountry ==
                                                        null ||
                                                    _selectedTimezone == null
                                                ? null
                                                : () async {
                                                    await _processPayment();
                                                  },
                                            child: Text(
                                              'Pay & Rent',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
