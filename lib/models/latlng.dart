/// A class representing a latitude and longitude coordinate.
class LatLng {
  /// The latitude coordinate.
  final double lat;
  
  /// The longitude coordinate.
  final double lng;

  /// Creates a new [LatLng] instance.
  ///
  /// @param lat The latitude coordinate.
  /// @param lng The longitude coordinate.
  const LatLng({
    required this.lat,
    required this.lng,
  });
}
