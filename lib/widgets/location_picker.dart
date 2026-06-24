import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng position, String address) onLocationSelected;
  final LatLng? initialLocation;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(-7.4011, 109.2352); // Default: Purwokerto
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = widget.initialLocation!;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission lokasi ditolak. Aktifkan di Settings.'),
            ),
          );
        }
        setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _selectedPosition = LatLng(pos.latitude, pos.longitude);
          _loadingLocation = false;
        });
        _mapController.move(_selectedPosition, 16);
        _notifyLocation(_selectedPosition);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _notifyLocation(LatLng pos) {
    final address =
        'Lat: ${pos.latitude.toStringAsFixed(6)}, Lng: ${pos.longitude.toStringAsFixed(6)}';
    widget.onLocationSelected(pos, address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition,
                    initialZoom: 15,
                    onTap: (tapPos, latLng) {
                      setState(() => _selectedPosition = latLng);
                      _notifyLocation(latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bank_sampah',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_loadingLocation)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF1B7A4D),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.pin_drop_rounded, color: Color(0xFF1B7A4D), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lat: ${_selectedPosition.latitude.toStringAsFixed(5)}, '
                  'Lng: ${_selectedPosition.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF1B3B2C)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '💡 Tap di peta untuk pilih lokasi penjemputan',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}