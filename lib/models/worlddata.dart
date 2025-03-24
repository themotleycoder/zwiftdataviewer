import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Represents a Zwift world with its properties.
///
/// This class contains information about a Zwift world, including its ID,
/// name, and URL for more information.
class WorldData {
  /// The unique identifier for the world.
  final int? id;
  
  /// The guest world ID enum value.
  final GuestWorldId? guestWorldId;
  
  /// The name of the world.
  final String? name;
  
  /// The URL with more information about the world.
  final String? url;

  /// Creates a WorldData instance.
  ///
  /// @param id The unique identifier for the world
  /// @param guestWorldId The guest world ID enum value
  /// @param name The name of the world
  /// @param url The URL with more information about the world
  const WorldData(this.id, this.guestWorldId, this.name, this.url);

  /// Creates a WorldData instance from a JSON map.
  ///
  /// @param json The JSON map containing the world data
  /// @return A new WorldData instance
  factory WorldData.fromJson(Map<String, dynamic> json) {
    return WorldData(
      json['id'] as int?,
      // Note: guestWorldId is not parsed from JSON as it's not in the API response
      null,
      json['name'] as String?,
      json['url'] as String?,
    );
  }

  /// Converts this WorldData instance to a JSON map.
  ///
  /// @return A map containing the world data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestWorldId': guestWorldId?.toString(),
      'name': name,
      'url': url,
    };
  }

  /// Creates a copy of this WorldData instance with the given fields replaced.
  ///
  /// @param id The new ID, or null to keep the current value
  /// @param guestWorldId The new guest world ID, or null to keep the current value
  /// @param name The new name, or null to keep the current value
  /// @param url The new URL, or null to keep the current value
  /// @return A new WorldData instance with the updated fields
  WorldData copyWith({
    int? id,
    GuestWorldId? guestWorldId,
    String? name,
    String? url,
  }) {
    return WorldData(
      id ?? this.id,
      guestWorldId ?? this.guestWorldId,
      name ?? this.name,
      url ?? this.url,
    );
  }

  @override
  String toString() {
    return 'WorldData(id: $id, guestWorldId: $guestWorldId, name: $name, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldData &&
        other.id == id &&
        other.guestWorldId == guestWorldId &&
        other.name == name &&
        other.url == url;
  }

  @override
  int get hashCode {
    return id.hashCode ^ guestWorldId.hashCode ^ name.hashCode ^ url.hashCode;
  }
}
