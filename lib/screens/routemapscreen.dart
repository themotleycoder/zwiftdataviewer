import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/streams_provider.dart';

class _Coordinate {
  final double lat;
  final double lng;
  
  _Coordinate(this.lat, this.lng);
}

class RouteMapScreen extends ConsumerStatefulWidget {
  final int activityId;

  const RouteMapScreen({super.key, required this.activityId});

  @override
  ConsumerState<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends ConsumerState<RouteMapScreen> {
  gmaps.GoogleMapController? _controller;
  final Set<gmaps.Polyline> _polylines = {};
  final Set<gmaps.Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(stravaActivityDetailsProvider);
    final streamsAsyncValue = ref.watch(streamsProvider(widget.activityId));

    // Trigger loading of activity details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(stravaActivityDetailsProvider.notifier)
          .loadActivityDetails(widget.activityId);
    });

    if (activity.id == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: streamsAsyncValue.when(
        data: (streams) {
          _updateMapData(activity, streams);
          return _buildMap(activity);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorView(error),
      ),
    );
  }

  Widget _buildMap(dynamic activity) {
    final startCoords = _parseLatLng(activity.startLatlng);
    final endCoords = _parseLatLng(activity.endLatlng);

    // Check if we have polyline data even if start/end coords are null
    bool hasPolylineData = activity.map?.summaryPolyline != null && 
                           activity.map!.summaryPolyline!.isNotEmpty;

    if (startCoords == null && endCoords == null && !hasPolylineData) {
      return _buildNoLocationView();
    }

    // Use first point from polyline if start/end coords are not available
    gmaps.LatLng? initialLocation;
    if (startCoords != null) {
      initialLocation = gmaps.LatLng(startCoords.lat, startCoords.lng);
    } else if (endCoords != null) {
      initialLocation = gmaps.LatLng(endCoords.lat, endCoords.lng);
    } else if (hasPolylineData) {
      // Decode polyline to get first point for initial camera position
      final polylinePoints = _decodePolyline(activity.map!.summaryPolyline!);
      if (polylinePoints.isNotEmpty) {
        initialLocation = polylinePoints.first;
      }
    }

    // Fallback to a default location if nothing is available
    initialLocation ??= const gmaps.LatLng(0.0, 0.0);

    
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: initialLocation,
        zoom: 16.0,
      ),
      polylines: _polylines,
      markers: _markers,
      onMapCreated: (gmaps.GoogleMapController controller) {
        _controller = controller;
        
        // Add a delay before fitting bounds to ensure map is fully loaded
        Future.delayed(const Duration(milliseconds: 500), () {
          _fitBounds();
        });
      },
      mapType: gmaps.MapType.normal,
      myLocationEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildNoLocationView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No GPS data available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'This activity does not contain location data.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading map data',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updateMapData(dynamic activity, dynamic streams) {
    _markers.clear();
    _polylines.clear();

    final startCoords = _parseLatLng(activity.startLatlng);
    final endCoords = _parseLatLng(activity.endLatlng);


    // Extract GPS track from polyline (preferred method)
    List<gmaps.LatLng> trackPoints = [];
    
    // Try to decode summary_polyline first
    if (activity.map?.summaryPolyline != null && activity.map!.summaryPolyline!.isNotEmpty) {
      try {
        trackPoints = _decodePolyline(activity.map!.summaryPolyline!);
      } catch (_) {
        // Ignore polyline decoding errors
      }
    }
    
    // Fallback to streams if no polyline - handle different stream data structures
    if (trackPoints.isEmpty && streams != null) {
      
      // Handle different possible stream structures
      List<dynamic>? streamsList;
      
      if (streams is Map && streams.containsKey('streams')) {
        streamsList = streams['streams'];
      } else if (streams.streams != null) {
        streamsList = streams.streams;
      } else if (streams is List) {
        streamsList = streams;
      }
      
      if (streamsList != null) {
        for (var stream in streamsList) {
          // Handle different latlng formats
          if (stream != null) {
            dynamic latlng;
            if (stream is Map) {
              latlng = stream['latlng'];
            } else {
              latlng = stream.latlng;
            }
            
            if (latlng != null && latlng is List && latlng.length >= 2) {
              try {
                double lat = (latlng[0] as num).toDouble();
                double lng = (latlng[1] as num).toDouble();
                if (lat != 0.0 || lng != 0.0) { // Skip null island coordinates
                  trackPoints.add(gmaps.LatLng(lat, lng));
                }
              } catch (_) {
                // Ignore latlng parsing errors
              }
            }
          }
        }
      }
    }

    // If we have track points, use them for the route
    if (trackPoints.isNotEmpty) {
      
      // Add start marker at first track point
      _markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('start'),
          position: trackPoints.first,
          infoWindow: const gmaps.InfoWindow(
            title: 'Start',
            snippet: 'Activity start location',
          ),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
        ),
      );

      // Add end marker at last track point
      _markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('end'),
          position: trackPoints.last,
          infoWindow: const gmaps.InfoWindow(
            title: 'End',
            snippet: 'Activity end location',
          ),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
        ),
      );

      // Create polyline with all track points
      _polylines.add(
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('route'),
          points: trackPoints,
          color: Colors.blue,
          width: 4,
        ),
      );
      
      
      // Trigger UI update
      setState(() {});
      
    } else {
      // Fallback to start/end coordinates if no track data
      if (startCoords != null) {
        _markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('start'),
            position: gmaps.LatLng(startCoords.lat, startCoords.lng),
            infoWindow: const gmaps.InfoWindow(
              title: 'Start',
              snippet: 'Activity start location',
            ),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
          ),
        );
      }

      if (endCoords != null) {
        _markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('end'),
            position: gmaps.LatLng(endCoords.lat, endCoords.lng),
            infoWindow: const gmaps.InfoWindow(
              title: 'End',
              snippet: 'Activity end location',
            ),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
          ),
        );
      }

      // Create simple polyline between start and end
      if (startCoords != null && endCoords != null) {
        _polylines.add(
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('route'),
            points: [
              gmaps.LatLng(startCoords.lat, startCoords.lng),
              gmaps.LatLng(endCoords.lat, endCoords.lng),
            ],
            color: Colors.blue,
            width: 4,
          ),
        );
      }
    }
  }

  _Coordinate? _parseLatLng(dynamic latLngData) {
    if (latLngData == null) {
      return null;
    }

    try {
      // Handle different data formats
      if (latLngData is String) {
        if (latLngData.isEmpty) return null;
        
        final Map<String, dynamic> coords = json.decode(latLngData);
        final double lat = coords['lat']?.toDouble() ?? 0.0;
        final double lng = coords['lng']?.toDouble() ?? 0.0;
        
        if (lat == 0.0 && lng == 0.0) {
          return null;
        }
        
        return _Coordinate(lat, lng);
      } else if (latLngData is List && latLngData.length >= 2) {
        // Handle array format [lat, lng]
        final double lat = latLngData[0]?.toDouble() ?? 0.0;
        final double lng = latLngData[1]?.toDouble() ?? 0.0;
        
        if (lat == 0.0 && lng == 0.0) {
          return null;
        }
        
        return _Coordinate(lat, lng);
      } else if (latLngData is Map<String, dynamic>) {
        // Handle map format {"lat": ..., "lng": ...}
        final double lat = latLngData['lat']?.toDouble() ?? 0.0;
        final double lng = latLngData['lng']?.toDouble() ?? 0.0;
        
        if (lat == 0.0 && lng == 0.0) {
          return null;
        }
        
        return _Coordinate(lat, lng);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  void _fitBounds() {
    
    if (_controller == null || _markers.isEmpty) {
      return;
    }

    if (_markers.length == 1) {
      return;
    }

    final bounds = _calculateBounds();
    _controller!.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  gmaps.LatLngBounds _calculateBounds() {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final pos = marker.position;
      minLat = minLat > pos.latitude ? pos.latitude : minLat;
      maxLat = maxLat < pos.latitude ? pos.latitude : maxLat;
      minLng = minLng > pos.longitude ? pos.longitude : minLng;
      maxLng = maxLng < pos.longitude ? pos.longitude : maxLng;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLng),
      northeast: gmaps.LatLng(maxLat, maxLng),
    );
  }

  /// Decodes a polyline string into a list of LatLng coordinates
  /// Uses Google's polyline algorithm: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      
      // Decode latitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      
      // Decode longitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      // Convert to decimal degrees
      double latDecimal = lat / 1e5;
      double lngDecimal = lng / 1e5;
      
      points.add(gmaps.LatLng(latDecimal, lngDecimal));
    }

    return points;
  }
}
