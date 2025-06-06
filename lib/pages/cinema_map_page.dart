import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CinemaLocation {
  final String name;
  final LatLng position;
  final String address;
  final String phone;
  final List<String> facilities;

  CinemaLocation({
    required this.name,
    required this.position,
    required this.address,
    required this.phone,
    required this.facilities,
  });
}

class CinemaMapPage extends StatefulWidget {
  const CinemaMapPage({super.key});

  @override
  State<CinemaMapPage> createState() => _CinemaMapPageState();
}

class _CinemaMapPageState extends State<CinemaMapPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(
    -6.2088,
    106.8456,
  ); // Default to Jakarta
  bool _isLoadingLocation = true;

  // Sample cinema locations (you can replace with real data)
  final List<CinemaLocation> _cinemaLocations = [
    CinemaLocation(
      name: "CGV Grand Indonesia",
      position: const LatLng(-6.1944, 106.8229),
      address: "Jl. M.H. Thamrin No.1, Jakarta Pusat",
      phone: "(021) 2358-2121",
      facilities: ["IMAX", "4DX", "Dolby Atmos", "Premium Class"],
    ),
    CinemaLocation(
      name: "XXI Plaza Indonesia",
      position: const LatLng(-6.1944, 106.8229),
      address: "Jl. M.H. Thamrin Kav. 28-30, Jakarta Pusat",
      phone: "(021) 3983-4021",
      facilities: ["Premiere", "Dolby Atmos", "IMAX"],
    ),
    CinemaLocation(
      name: "Cineplex Lippo Mall Kemang",
      position: const LatLng(-6.2615, 106.8106),
      address: "Jl. Kemang Raya No.2, Jakarta Selatan",
      phone: "(021) 719-2121",
      facilities: ["4DX", "Gold Class", "Standard"],
    ),
    CinemaLocation(
      name: "CGV Blitz Megaplex",
      position: const LatLng(-6.2297, 106.8253),
      address: "Jl. Jend. Sudirman Kav. 25, Jakarta Selatan",
      phone: "(021) 5212-0808",
      facilities: ["IMAX", "Velvet Class", "Gold Class"],
    ),
    CinemaLocation(
      name: "XXI Senayan City",
      position: const LatLng(-6.2248, 106.7988),
      address: "Jl. Asia Afrika No.8, Jakarta Selatan",
      phone: "(021) 7278-1200",
      facilities: ["Premiere", "Dolby Atmos", "4DX"],
    ),
    CinemaLocation(
      name: "CGV Paris Van Java",
      position: const LatLng(-6.8952, 107.5732),
      address: "Jl. Sukajadi No.131-139, Bandung",
      phone: "(022) 8200-6969",
      facilities: ["IMAX", "Gold Class", "4DX"],
    ),
    CinemaLocation(
      name: "Century Theaters at Mountain View",
      position: const LatLng(37.4138, -122.0772),
      address: "1500 N Shoreline Blvd, Mountain View, CA 94043",
      phone: "(650) 960-0970",
      facilities: ["IMAX", "XD", "Dolby Atmos", "Luxury Loungers"],
    ),
    CinemaLocation(
      name: "AMC Mountain View 16",
      position: const LatLng(37.4019, -122.0784),
      address: "2000 W El Camino Real, Mountain View, CA 94040",
      phone: "(650) 969-6000",
      facilities: [
        "Dolby Cinema",
        "PRIME",
        "Dine-In Theater",
        "Recliner Seating",
      ],
    ),
    CinemaLocation(
      name: "Aquarius Theatre",
      position: const LatLng(37.3861, -122.0839),
      address: "430 Emerson St, Palo Alto, CA 94301",
      phone: "(650) 327-3241",
      facilities: ["Independent Films", "Art House", "Historic Theater"],
    ),
    CinemaLocation(
      name: "CGV Jogja City Mall",
      position: const LatLng(-7.7326, 110.3671),
      address: "Jl. Magelang No.18, Yogyakarta",
      phone: "(0274) 563888",
      facilities: ["IMAX", "4DX", "Sweetbox", "Gold Class"],
    ),
    CinemaLocation(
      name: "XXI Malioboro Mall",
      position: const LatLng(-7.7956, 110.3695),
      address: "Jl. Malioboro No.52-58, Yogyakarta",
      phone: "(0274) 563999",
      facilities: ["Premiere", "Dolby Atmos", "Standard"],
    ),
    CinemaLocation(
      name: "Studio 21 Ambarrukmo Plaza",
      position: const LatLng(-7.7821, 110.4085),
      address: "Jl. Laksda Adisucipto No.1, Yogyakarta",
      phone: "(0274) 488568",
      facilities: ["Gold Class", "Dolby Atmos", "Standard"],
    ),
    CinemaLocation(
      name: "Cinema XXI Lippo Plaza Jogja",
      position: const LatLng(-7.7454, 110.3576),
      address: "Jl. Laksda Adisucipto No.32-34, Yogyakarta",
      phone: "(0274) 560021",
      facilities: ["Standard", "Dolby Atmos"],
    ),
    CinemaLocation(
      name: "CGV Hartono Mall",
      position: const LatLng(-7.7389, 110.3878),
      address: "Jl. Ring Road Utara, Yogyakarta",
      phone: "(0274) 5305888",
      facilities: ["4DX", "Gold Class", "Standard"],
    ),
  ];

  bool _mapError = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        await _getCurrentLocation();
      } else if (status.isDenied) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationPermissionDialog();
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationSettingsDialog();
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting location permission: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Layanan lokasi tidak aktif. Silakan aktifkan GPS.',
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });

        // Move map to current location with animation
        _mapController.move(_currentLocation, 13.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
    }
  }

  void _showCinemaDetails(CinemaLocation cinema) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_movies,
                            color: Colors.red[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cinema.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bioskop",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      "Alamat",
                      cinema.address,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.phone, "Telepon", cinema.phone),
                    const SizedBox(height: 24),
                    const Text(
                      "Fasilitas",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cinema.facilities.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            facility,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.red[600],
                    //       padding: const EdgeInsets.symmetric(vertical: 16),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.pop(context);

                    //       // TODO: Navigate to booking or more details
                    //     },
                    //     child: const Text(
                    //       "Lihat Jadwal Film",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Lokasi Diperlukan'),
          content: const Text(
            'Aplikasi memerlukan izin lokasi untuk menampilkan posisi Anda di peta dan menemukan bioskop terdekat.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Lokasi Ditolak'),
          content: const Text(
            'Izin lokasi telah ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapErrorFallback() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Peta tidak dapat dimuat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi masalah saat memuat peta.\nSilakan coba lagi nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _mapError = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAEDFF7),
                foregroundColor: Colors.black87,
              ),
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 16),
            // Show cinema locations as list when map fails
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAEDFF7),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      width: double.infinity,
                      child: const Text(
                        'Daftar Bioskop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cinemaLocations.length,
                        itemBuilder: (context, index) {
                          final cinema = _cinemaLocations[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.local_movies,
                                color: Colors.red[600],
                                size: 20,
                              ),
                            ),
                            title: Text(
                              cinema.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              cinema.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () => _showCinemaDetails(cinema),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 11.0,
        maxZoom: 18.0,
        minZoom: 3.0,
        onMapReady: () {
          // Map is ready, no need for special handling
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.responsiah',
          maxZoom: 18,
          errorTileCallback: (tile, error, stackTrace) {
            // Handle tile loading errors by switching to fallback
            if (mounted) {
              setState(() {
                _mapError = true;
              });
            }
          },
          retinaMode: false, // Disable retina mode to reduce OpenGL load
        ),
        MarkerLayer(
          markers: [
            // Current location marker
            if (!_isLoadingLocation)
              Marker(
                point: _currentLocation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            // Cinema markers
            ..._cinemaLocations.map(
              (cinema) => Marker(
                point: cinema.position,
                child: GestureDetector(
                  onTap: () => _showCinemaDetails(cinema),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_movies,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bioskop Terdekat"),
        backgroundColor: const Color(0xFFAEDFF7),
        elevation: 0,
      ),
      body: Stack(
        children: [
          _mapError ? _buildMapErrorFallback() : _buildFlutterMap(),
          if (_isLoadingLocation)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Mendapatkan lokasi Anda...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                if (!_isLoadingLocation && !_mapError) {
                  _mapController.move(_currentLocation, 13.0);
                }
              },
              child: Icon(Icons.my_location, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
