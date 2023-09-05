import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/filtered_routes_provider.dart';
import '../providers/route_provider.dart';
import '../providers/world_select_provider.dart';
import '../utils/constants.dart';

double rowHeight = 40;

class WorldDetailScreen extends ConsumerWidget {
  const WorldDetailScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorldData worldData = ref.watch(selectedWorldProvider);
    final List<RouteData> routeDataModel = ref.watch(filteredRoutesProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(worldData.name ?? "", style: constants.appBarTextStyle),
          backgroundColor: white,
          elevation: 0.0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: zdvMidBlue,
          useInkWell: true,
        ),
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: routeDataModel.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return ExpandingCard(routeDataModel[index]);
            }),
      ),
    );
  } //);
}

class ExpandingCard extends StatefulWidget {
  final RouteData _routeData;

  const ExpandingCard(this._routeData, {super.key});

  @override
  _ExpandingCardState createState() => _ExpandingCardState();
}

class _ExpandingCardState extends State<ExpandingCard> {
  @override
  Widget build(BuildContext context) {
    String routeName = widget._routeData.routeName ?? "";
    if (widget._routeData.eventOnly == "Event Only") {
      routeName = "$routeName (Event Only)";
    }
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: defaultCardElevation,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: false,
                  tapHeaderToExpand: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                    child: Text(
                      routeName,
                      // style: widget._routeData!=null?widget._routeData.completed
                      //     Constants.bodyTextStyleComplete
                      //     : Constants.bodyTextStyle,
                    )),
                collapsed: Text(
                  widget._routeData.distance ?? "",
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    routeLineItem(
                        'Distance', widget._routeData.distance ?? "NA"),
                    routeLineItem(
                        'Altitiude', widget._routeData.altitude ?? "NA"),
                    routeLineItem(
                        'Additonal Info', widget._routeData.eventOnly ?? "NA"),
                    eventLineItem('Route Completed', widget._routeData),
                    iconLineItem(
                        'Route Details',
                        const Icon(Icons.arrow_forward_ios),
                        widget._routeData.url ?? "NA"),
                    // routeProfile(),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  routeProfile() {}

  List<Widget> loadMapImage(int worldId, int routeId) {
    final List<Widget> painters = <Widget>[];

    String url =
        'https://zwifthacks.com/app/routes/svg/route/?world=$worldId&route=$routeId&showprofile=1&showlegend=1';

    List<String> uriNames = <String>[url];

    for (String uriName in uriNames) {
      painters.add(
        SvgPicture.network(
          uriName,
          placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator()),
        ),
      );
    }

    return painters;
  }

  Widget routeLineItem(String title, String value) {
    return SizedBox(
        height: rowHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: constants.headerTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              Text(
                value,
                style: constants.bodyTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ));
  }

  Widget eventLineItem(String title, RouteData routeData) {
    return SizedBox(
        height: rowHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: constants.headerTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              // Container(
              //     height: 50,
              Switch(
                value: routeData.completed ?? false,
                onChanged: (value) {
                  routeData.completed = value;
                  setState(() {});
                  // Provider.of<RouteDataModel>(context, listen: false)
                  //     .updateRouteData();
                },
                activeTrackColor: zdvmLgtBlue,
                activeColor: zdvmMidBlue[100],
              ), //),
            ],
          ),
        ));
  }

  Widget iconLineItem(String title, Icon value, String url) {
    return SizedBox(
        height: rowHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: constants.headerTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              IconButton(
                icon: value,
                color: zdvmMidBlue[100],
                onPressed: () => launchURL(url),
              ),
            ],
          ),
        ));
  }

  launchURL(String url) async {
    String site = url.substring(url.indexOf('//') + 2);
    String path = site.substring(site.indexOf('/'));
    site = site.substring(0, site.indexOf('/'));
    final Uri uri = Uri.https(site, path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
