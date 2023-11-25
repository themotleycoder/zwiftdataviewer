import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/filters/filters_provider.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

class FilterButton extends ConsumerWidget {
  final bool isActive;

  const FilterButton({required this.isActive, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var guestWorldFilter = ref.watch(guestWorldFiltersNotifier.notifier);

    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child:
              // Consumer<ActivitiesDataModel>(
              //   builder: (context, model, _) {
              PopupMenuButton<GuestWorldId>(
            key: AppKeys.filterButton,
            tooltip: 'filter',
            //ArchSampleLocalizations.of(context).filterTodos,
            initialValue: GuestWorldId.all,
            onSelected: (filter) =>
                ref.read(guestWorldFiltersNotifier.notifier).setFilter(filter),
            itemBuilder: (BuildContext context) => _items(context, ref),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          )
          //   },
          // ),
          ),
    );
  }

  List<PopupMenuItem<GuestWorldId>> _items(
      BuildContext context, WidgetRef ref) {
    var guestWorldFilter = ref.watch(guestWorldFiltersNotifier.notifier);

    final activeStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;

    return [
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.allFilter,
        value: GuestWorldId.all,
        child: Text(
          'Show All', //ArchSampleLocalizations.of(context).showActive,
          style: guestWorldFilter.filter == GuestWorldId.all
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.franceFilter,
        value: GuestWorldId.france,
        child: Text(
          'France', //ArchSampleLocalizations.of(context).showAll,
          style: guestWorldFilter.filter == GuestWorldId.all
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.innsbruckFilter,
        value: GuestWorldId.innsbruck,
        child: Text(
          'Innsbruck', //ArchSampleLocalizations.of(context).showActive,
          style: guestWorldFilter.filter == GuestWorldId.innsbruck
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.londonFilter,
        value: GuestWorldId.london,
        child: Text(
          'London', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter == GuestWorldId.london
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.newyorkFilter,
        value: GuestWorldId.newyork,
        child: Text(
          'New York', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter == GuestWorldId.newyork
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.parisFilter,
        value: GuestWorldId.paris,
        child: Text(
          'Paris', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter == GuestWorldId.paris
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.richmondFilter,
        value: GuestWorldId.richmond,
        child: Text(
          'Richmond', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter == GuestWorldId.richmond
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.watopiaFilter,
        value: GuestWorldId.watopia,
        child: Text(
          'Watopia', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter == GuestWorldId.watopia
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.othersFilter,
        value: GuestWorldId.watopia,
        child: Text(
          'Others', //ArchSampleLocalizations.of(context).showCompleted,
          style: guestWorldFilter.filter.toString() == 'others'
              ? activeStyle
              : defaultStyle,
        ),
      ),
    ];
  }
}
