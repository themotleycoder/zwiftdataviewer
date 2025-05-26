import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routefilter_provider.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

class ImprovedRouteFilterWidget extends ConsumerStatefulWidget {
  const ImprovedRouteFilterWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ImprovedRouteFilterWidget> createState() => _ImprovedRouteFilterWidgetState();
}

class _ImprovedRouteFilterWidgetState extends ConsumerState<ImprovedRouteFilterWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final routeFilters = ref.watch(distanceFiltersNotifier);
    final AsyncValue<List<RouteData>> routeDataModel = ref.watch(allRoutesProvider);

    return routeDataModel.when(
      data: (routes) => _buildFilterWidget(context, routes, routeFilters),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterWidget(BuildContext context, List<RouteData> routes, RouteFilterObject routeFilters) {
    final hasActiveFilters = _hasActiveFilters(routeFilters, routes);
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Column(
        children: [
          _buildFilterHeader(hasActiveFilters, routeFilters),
          if (_isExpanded) _buildFilterContent(routes, routeFilters),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(bool hasActiveFilters, RouteFilterObject routeFilters) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: hasActiveFilters ? zdvMidBlue : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hasActiveFilters ? zdvMidBlue : Colors.grey[800],
                    ),
                  ),
                  if (hasActiveFilters) _buildActiveFiltersPreview(routeFilters),
                ],
              ),
            ),
            if (hasActiveFilters)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearAllFilters,
                tooltip: 'Clear all filters',
              ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersPreview(RouteFilterObject routeFilters) {
    final List<String> activeFilters = [];
    
    if (routeFilters.worlds.isNotEmpty) {
      if (routeFilters.worlds.length == 1) {
        activeFilters.add(routeFilters.worlds.first.name!);
      } else {
        activeFilters.add('${routeFilters.worlds.length} worlds');
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Wrap(
        spacing: 8.0,
        children: activeFilters.map((filter) => Chip(
          label: Text(
            filter,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: zdvMidBlue.withOpacity(0.1),
          side: BorderSide(color: zdvMidBlue.withOpacity(0.3)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )).toList(),
      ),
    );
  }

  Widget _buildFilterContent(List<RouteData> routes, RouteFilterObject routeFilters) {
    final maxDistance = _getMaxDistance(routes);
    final maxElevation = _getMaxElevation(routes);
    final units = Conversions.units(ref);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit to 60% of screen height
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              _buildDistanceFilter(routeFilters, maxDistance, units),
              const SizedBox(height: 24),
              _buildElevationFilter(routeFilters, maxElevation, units),
              const SizedBox(height: 24),
              _buildWorldFilter(routeFilters),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceFilter(RouteFilterObject routeFilters, double maxDistance, Map<String, String> units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance (${units['distance']})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _getSafeDistanceRange(routeFilters, maxDistance),
          max: maxDistance,
          divisions: 20,
          activeColor: zdvMidBlue,
          labels: RangeLabels(
            Conversions.metersToDistance(ref, routeFilters.distance.start).toStringAsFixed(1),
            Conversions.metersToDistance(ref, routeFilters.distance.end).toStringAsFixed(1),
          ),
          onChanged: (RangeValues values) {
            _updateDistanceFilter(values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${Conversions.metersToDistance(ref, routeFilters.distance.start).toStringAsFixed(1)} ${units['distance']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${Conversions.metersToDistance(ref, routeFilters.distance.end).toStringAsFixed(1)} ${units['distance']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElevationFilter(RouteFilterObject routeFilters, double maxElevation, Map<String, String> units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elevation (${units['height']})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _getSafeElevationRange(routeFilters, maxElevation),
          max: maxElevation,
          divisions: 20,
          activeColor: zdvMidBlue,
          labels: RangeLabels(
            Conversions.metersToHeight(ref, routeFilters.elevation.start).toStringAsFixed(0),
            Conversions.metersToHeight(ref, routeFilters.elevation.end).toStringAsFixed(0),
          ),
          onChanged: (RangeValues values) {
            _updateElevationFilter(values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${Conversions.metersToHeight(ref, routeFilters.elevation.start).toStringAsFixed(0)} ${units['height']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${Conversions.metersToHeight(ref, routeFilters.elevation.end).toStringAsFixed(0)} ${units['height']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorldFilter(RouteFilterObject routeFilters) {
    final allWorlds = allWorldsConfig.values.toList();
    final selectedWorlds = Set<String>.from(routeFilters.worlds.map((w) => w.name!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Worlds',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (selectedWorlds.isNotEmpty)
              TextButton(
                onPressed: _clearWorldFilter,
                child: const Text('Clear all'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: allWorlds.map((world) {
            final isSelected = selectedWorlds.contains(world.name);
            return FilterChip(
              label: Text(world.name!),
              selected: isSelected,
              onSelected: (selected) {
                _toggleWorldFilter(world, selected);
              },
              selectedColor: zdvMidBlue.withOpacity(0.2),
              checkmarkColor: zdvMidBlue,
              side: BorderSide(
                color: isSelected ? zdvMidBlue : Colors.grey.withOpacity(0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text('Clear All'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => setState(() => _isExpanded = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: zdvMidBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }

  bool _hasActiveFilters(RouteFilterObject routeFilters, List<RouteData> routes) {
    if (routes.isEmpty) return false;
    
    final maxDistance = _getMaxDistance(routes);
    final maxElevation = _getMaxElevation(routes);
    
    return routeFilters.distance.start > 0 ||
           routeFilters.distance.end < maxDistance ||
           routeFilters.elevation.start > 0 ||
           routeFilters.elevation.end < maxElevation ||
           routeFilters.worlds.isNotEmpty;
  }

  RangeValues _getSafeDistanceRange(RouteFilterObject routeFilters, double maxDistance) {
    final start = routeFilters.distance.start.clamp(0.0, maxDistance);
    final end = routeFilters.distance.end.clamp(start, maxDistance);
    return RangeValues(start, end);
  }

  RangeValues _getSafeElevationRange(RouteFilterObject routeFilters, double maxElevation) {
    final start = routeFilters.elevation.start.clamp(0.0, maxElevation);
    final end = routeFilters.elevation.end.clamp(start, maxElevation);
    return RangeValues(start, end);
  }

  double _getMaxDistance(List<RouteData> routes) {
    if (routes.isEmpty) return 100000;
    return routes.map((r) => r.distanceMeters!.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  double _getMaxElevation(List<RouteData> routes) {
    if (routes.isEmpty) return 5000;
    return routes.map((r) => r.altitudeMeters!.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  void _updateDistanceFilter(RangeValues values) {
    final currentFilters = ref.read(distanceFiltersNotifier);
    ref.read(distanceFiltersNotifier.notifier).setFilter(
      RouteFilterObject(values, currentFilters.elevation, currentFilters.worlds),
    );
  }

  void _updateElevationFilter(RangeValues values) {
    final currentFilters = ref.read(distanceFiltersNotifier);
    ref.read(distanceFiltersNotifier.notifier).setFilter(
      RouteFilterObject(currentFilters.distance, values, currentFilters.worlds),
    );
  }

  void _toggleWorldFilter(WorldData world, bool selected) {
    final currentFilters = ref.read(distanceFiltersNotifier);
    final currentWorlds = List<WorldData>.from(currentFilters.worlds);
    
    if (selected) {
      if (!currentWorlds.any((w) => w.name == world.name)) {
        currentWorlds.add(world);
      }
    } else {
      currentWorlds.removeWhere((w) => w.name == world.name);
    }
    
    ref.read(distanceFiltersNotifier.notifier).setFilter(
      RouteFilterObject(currentFilters.distance, currentFilters.elevation, currentWorlds),
    );
  }

  void _clearWorldFilter() {
    final currentFilters = ref.read(distanceFiltersNotifier);
    ref.read(distanceFiltersNotifier.notifier).setFilter(
      RouteFilterObject(currentFilters.distance, currentFilters.elevation, []),
    );
  }

  void _clearAllFilters() {
    final AsyncValue<List<RouteData>> routeDataModel = ref.read(allRoutesProvider);
    routeDataModel.whenData((routes) {
      final maxDistance = _getMaxDistance(routes);
      final maxElevation = _getMaxElevation(routes);
      
      ref.read(distanceFiltersNotifier.notifier).setFilter(
        RouteFilterObject(
          RangeValues(0, maxDistance),
          RangeValues(0, maxElevation),
          [],
        ),
      );
    });
  }
}
