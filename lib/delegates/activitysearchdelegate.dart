import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;

import '../screens/ridedetailscreen.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class ActivitySearch extends SearchDelegate<SummaryActivity> {
  final List<SummaryActivity> activities;
  SummaryActivity? selectedResult;

  ActivitySearch(this.activities);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          query = '';
          selectedResult = null;
          buildResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<SummaryActivity> suggestionList = [];
    selectedResult = null;
    query.isEmpty
        ? suggestionList = activities //In the true case
        : suggestionList.addAll(activities.where(
            // In the false case
            (element) => element.name.toLowerCase().contains(query),
          ));
    final Strava strava = Strava(globals.isInDebug, clientSecret);

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return buildListItem(context, suggestionList[index], strava);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<SummaryActivity> results = selectedResult == null
        ? activities
        : activities
            .where(
                (element) => element.name.contains(selectedResult?.name ?? ''))
            .toList();

    final Strava strava = Strava(globals.isInDebug, clientSecret);

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (BuildContext context, int index) => Container(),
      itemBuilder: (BuildContext context, int index) {
        return buildListItem(context, results[index], strava);
        // margin: EdgeInsets.all(1.0),
      },
    );
  }

  Widget buildListItem(
      BuildContext context, SummaryActivity summaryActivity, Strava strava) {
    return Container(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        child: Center(
            child: InkWell(
                child: Card(
                    color: Colors.white,
                    elevation: defaultCardElevation,
                    child: ListTile(
                      leading: const Icon(Icons.directions_bike,
                          size: 32.0, color: zdvOrange),
                      title: Text(summaryActivity.name,
                          style: constants.headerFontStyle),
                      subtitle: Text(DateFormat.yMd()
                          .add_jm()
                          .format(summaryActivity.startDateLocal)),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: zdvmMidBlue[100],
                      ),
                      onTap: () {
                        // Set the selected activity before navigating
                        final container = ProviderScope.containerOf(context);
                        container.read(detailTabsNotifier.notifier).setIndex(0);
                        container.read(selectedActivityProvider.notifier).selectActivity(summaryActivity);
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return const DetailScreen();
                            },
                          ),
                        );
                      },
                      // onItemClick(_activities[index], context);
                    )))));
  }
}
