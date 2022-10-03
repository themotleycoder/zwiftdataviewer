import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

class FilterButton extends StatelessWidget {
  final bool isActive;

  const FilterButton({required this.isActive, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Consumer<ActivitiesDataModel>(
          builder: (context, model, _) {
            return PopupMenuButton<GuestWorldId>(
              key: AppKeys.filterButton,
              tooltip: 'filter',
              //ArchSampleLocalizations.of(context).filterTodos,
              initialValue: model.filter,
              onSelected: (filter) => model.filter = filter,
              itemBuilder: (BuildContext context) => _items(context, model),
              icon: const Icon(Icons.filter_list),
            );
          },
        ),
      ),
    );
  }

  List<PopupMenuItem<GuestWorldId>> _items(
      BuildContext context, ActivitiesDataModel store) {
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyText2
        ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final defaultStyle = Theme.of(context).textTheme.bodyText2;

    return [
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.allFilter,
        value: GuestWorldId.all,
        child: Text(
          'Show All', //ArchSampleLocalizations.of(context).showActive,
          style: store.filter == GuestWorldId.all ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.franceFilter,
        value: GuestWorldId.france,
        child: Text(
          'France', //ArchSampleLocalizations.of(context).showAll,
          style: store.filter == GuestWorldId.all ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.innsbruckFilter,
        value: GuestWorldId.innsbruck,
        child: Text(
          'Innsbruck', //ArchSampleLocalizations.of(context).showActive,
          style: store.filter == GuestWorldId.innsbruck
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.londonFilter,
        value: GuestWorldId.london,
        child: Text(
          'London', //ArchSampleLocalizations.of(context).showCompleted,
          style:
              store.filter == GuestWorldId.london ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.newyorkFilter,
        value: GuestWorldId.newyork,
        child: Text(
          'New York', //ArchSampleLocalizations.of(context).showCompleted,
          style:
              store.filter == GuestWorldId.newyork ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.parisFilter,
        value: GuestWorldId.paris,
        child: Text(
          'Paris', //ArchSampleLocalizations.of(context).showCompleted,
          style:
              store.filter == GuestWorldId.paris ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.richmondFilter,
        value: GuestWorldId.richmond,
        child: Text(
          'Richmond', //ArchSampleLocalizations.of(context).showCompleted,
          style: store.filter == GuestWorldId.richmond
              ? activeStyle
              : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.watopiaFilter,
        value: GuestWorldId.watopia,
        child: Text(
          'Watopia', //ArchSampleLocalizations.of(context).showCompleted,
          style:
              store.filter == GuestWorldId.watopia ? activeStyle : defaultStyle,
        ),
      ),
      PopupMenuItem<GuestWorldId>(
        key: AppKeys.othersFilter,
        value: GuestWorldId.watopia,
        child: Text(
          'Others', //ArchSampleLocalizations.of(context).showCompleted,
          style:
              store.filter.toString() == 'others' ? activeStyle : defaultStyle,
        ),
      ),
    ];
  }
}
