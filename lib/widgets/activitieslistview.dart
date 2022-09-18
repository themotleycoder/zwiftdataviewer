import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class ActivitiesListView extends StatelessWidget {
  final List<SummaryActivity> _activities;

  const ActivitiesListView(this._activities, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Strava? strava = Strava(Globals.isInDebug, secret);
    // return Selector<ActivitiesDataModel, List<SummaryActivity>>(
    //     selector: (_, model) => model.filteredActivities,
    //     builder: (context, _activities, _) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: ListView.separated(
        itemCount: _activities == null ? 0 : _activities.length,
        separatorBuilder: (BuildContext context, int index) => Container(
            // padding: EdgeInsets.all(5.0),
            // child: Center(),
            // color: Colors.white,
            // margin: EdgeInsets.all(1.0),
            ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Center(
                child: InkWell(
              child: Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.directions_bike,
                        size: 32.0, color: zdvOrange),
                    title: Text(_activities[index].name ?? "",
                        style: Constants.headerFontStyle),
                    subtitle: Text(DateFormat.yMd()
                        .add_jm()
                        .format(_activities[index].startDateLocal!)),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: zdvmMidBlue[100],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return DetailScreen(
                              id: _activities[index].id ?? -1,
                              strava: strava!,
                              // onRemove: () {
                              //   Navigator.pop(context);
                              //   onRemove(context, todo);
                              // },
                            );
                          },
                        ),
                      );
                    },
                    // onItemClick(_activities[index], context);
                  )),
            )),
            // margin: EdgeInsets.all(1.0),
          );
        },
      ),
    );
    // });
  }
}

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
          query = "";
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
    // query.isEmpty
    //     ? suggestionList = [] //In the true case
    //     : suggestionList.addAll(activities.where(
    //         // In the false case
    //         (element) => element.name.toLowerCase().contains(query),
    //       ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList[index].name ?? "NA",
          ),
          leading:
              query.isEmpty ? const Icon(Icons.access_time) : const SizedBox(),
          onTap: () {
            selectedResult = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<SummaryActivity> results = selectedResult == null
        ? activities
        : activities
            .where(
                (element) => element.name!.contains(selectedResult?.name ?? ""))
            .toList();

    final Strava strava = Strava(Globals.isInDebug, secret);

    return Container(
      child: ListView.separated(
        itemCount: results == null ? 0 : results.length,
        separatorBuilder: (BuildContext context, int index) => Container(
            // padding: EdgeInsets.all(5.0),
            // child: Center(),
            // color: Colors.white,
            // margin: EdgeInsets.all(1.0),
            ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Center(
                child: InkWell(
              child: Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.directions_bike,
                        size: 32.0, color: zdvmOrange),
                    title: Text(results[index].name ?? "NA",
                        style: Constants.headerFontStyle),
                    subtitle: Text(DateFormat.yMd().add_jm().format(
                        results[index].startDateLocal ?? DateTime.now())),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: zdvmMidBlue[100],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return DetailScreen(
                              id: results[index].id ?? -1,
                              strava: strava,
                              // onRemove: () {
                              //   Navigator.pop(context);
                              //   onRemove(context, todo);
                              // },
                            );
                          },
                        ),
                      );
                    },
                    // onItemClick(_activities[index], context);
                  )),
            )),
            // margin: EdgeInsets.all(1.0),
          );
        },
      ),
    );
  }
}
