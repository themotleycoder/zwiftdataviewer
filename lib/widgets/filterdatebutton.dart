import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';

import '../providers/filters_provider.dart';

class FilterDateButton extends ConsumerWidget {
  final bool isActive;

  const FilterDateButton({required this.isActive, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // var activities = ref.watch(activitiesProvider.notifier);
    final dateFilterProv = ref.read(dateFiltersProvider.notifier);
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child:
              // Consumer<ActivitiesDataModel>(
              //   builder: (context, model, _) {
              PopupMenuButton<DateFilter>(
            key: AppKeys.filterDateButton,
            tooltip: 'filter',
            //ArchSampleLocalizations.of(context).filterTodos,
            // initialValue: model.dateFilter,
            onSelected: (dateFilter) => dateFilterProv.setFilter(dateFilter),
            itemBuilder: (BuildContext context) => _items(context, ref),
            icon: const Icon(Icons.filter_list, color: Colors.black),
          )
          // },
          // ),
          ),
    );
  }

  List<PopupMenuItem<DateFilter>> _items(BuildContext context, WidgetRef ref) {
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;

    final dateFilter = ref.watch(dateFiltersProvider.notifier);

    return [
      PopupMenuItem<DateFilter>(
        key: AppKeys.allFilter,
        value: DateFilter.all,
        child: Text(
          'All Time', //ArchSampleLocalizations.of(context).showActive,
          style:
              dateFilter.filter == DateFilter.all ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.yearFilter,
        value: DateFilter.year,
        child: Text(
          '365 Days', //ArchSampleLocalizations.of(context).showAll,
          style:
              dateFilter.filter == DateFilter.year ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.monthFilter,
        value: DateFilter.month,
        child: Text(
          '30 Days', //ArchSampleLocalizations.of(context).showAll,
          style: dateFilter.filter == DateFilter.month
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.weekFilter,
        value: DateFilter.week,
        child: Text(
          '7 Days', //ArchSampleLocalizations.of(context).showActive,
          style:
              dateFilter.filter == DateFilter.week ? activeStyle : defaultStyle,
        ),
      ),
    ];
  }
}
