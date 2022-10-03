import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/utils/constants.dart';

class FilterDateButton extends StatelessWidget {
  final bool isActive;

  const FilterDateButton({required this.isActive, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Consumer<ActivitiesDataModel>(
          builder: (context, model, _) {
            return PopupMenuButton<DateFilter>(
              key: AppKeys.filterDateButton,
              tooltip: 'filter',
              //ArchSampleLocalizations.of(context).filterTodos,
              initialValue: model.dateFilter,
              onSelected: (dateFilter) => model.dateFilter = dateFilter,
              itemBuilder: (BuildContext context) => _items(context, model),
              icon: const Icon(Icons.filter_list),
            );
          },
        ),
      ),
    );
  }

  List<PopupMenuItem<DateFilter>> _items(
      BuildContext context, ActivitiesDataModel store) {
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final defaultStyle = Theme.of(context).textTheme.bodyText2;

    return [
      PopupMenuItem<DateFilter>(
        key: AppKeys.allFilter,
        value: DateFilter.all,
        child: Text(
          'All Time', //ArchSampleLocalizations.of(context).showActive,
          style: store.filter == DateFilter.all ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.franceFilter,
        value: DateFilter.year,
        child: Text(
          '365 Days', //ArchSampleLocalizations.of(context).showAll,
          style: store.filter == DateFilter.year ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.franceFilter,
        value: DateFilter.month,
        child: Text(
          '30 Days', //ArchSampleLocalizations.of(context).showAll,
          style: store.filter == DateFilter.month ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<DateFilter>(
        key: AppKeys.innsbruckFilter,
        value: DateFilter.week,
        child: Text(
          '7 Days', //ArchSampleLocalizations.of(context).showActive,
          style: store.filter == DateFilter.week ? activeStyle : defaultStyle,
        ),
      ),
    ];
  }
}
