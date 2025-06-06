import 'package:flutter/material.dart';
import 'package:responsiah/database/database_helper.dart';
import 'package:responsiah/services/session_service.dart';
import 'package:intl/intl.dart';

class RentalHistoryPage extends StatefulWidget {
  @override
  _RentalHistoryPageState createState() => _RentalHistoryPageState();
}

class _RentalHistoryPageState extends State<RentalHistoryPage> {
  List<MovieRental> _rentalHistory = [];

  @override
  void initState() {
    super.initState();
    _loadRentalHistory();
  }

  Future<void> _loadRentalHistory() async {
    final currentUserId = SessionService.currentUserId;
    if (currentUserId != null) {
      final rentals = DatabaseHelper.getUserRentals(currentUserId);
      setState(() {
        _rentalHistory = rentals;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental History'),
        backgroundColor: Color(0xFFAEDFF7),
      ),
      body: _rentalHistory.isEmpty
          ? Center(
              child: Text('No rental history available.'),
            )
          : ListView.builder(
              itemCount: _rentalHistory.length,
              itemBuilder: (context, index) {
                final rental = _rentalHistory[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie poster image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            rental.imageUrl.isNotEmpty
                                ? rental.imageUrl
                                : 'https://via.placeholder.com/80x120?text=No+Image',
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        // Movie details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rental.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                  'Rental Date: ${DateFormat('yyyy-MM-dd – hh:mm a').format(rental.rentalDate)}'),
                              Text(
                                  'Expiry Date: ${DateFormat('yyyy-MM-dd – hh:mm a').format(rental.expiryDate)}'),
                              Text('Price: ${rental.harga} ${rental.currency}'),
                              Text('Payment Time: ${rental.paymentTime}'),
                              Text('Status: ${rental.statusPembelian}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
