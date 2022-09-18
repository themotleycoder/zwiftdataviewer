import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/RouteDataModel.dart';
import 'package:zwiftdataviewer/models/WorldDataModel.dart';
// import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';
//import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;
import 'package:zwiftdataviewer/utils/theme.dart';

double rowHeight = 40;

class WorldDetailScreen extends StatelessWidget {
  final WorldData worldData;
  final int worldId;

  WorldDetailScreen({required this.worldId, required this.worldData})
      : super(key: AppKeys.todoDetailsScreen);

  @override
  Widget build(BuildContext context) {
    // final Map<String, String> units = Conversions.units(context);
    return Consumer<RouteDataModel>(builder: (context, routeDataModel, child) {
      // final List<RouteData> routeData = routeDataModel.routeData[worldId];
      routeDataModel.filter = routeType.basiconly;
      routeDataModel.filterWorldId = worldId;
      if (routeDataModel.isLoading) {
        return Center(
          child: CircularProgressIndicator(
            key: AppKeys.activitiesLoading,
          ),
        );
      }

      return Selector<RouteDataModel, List<RouteData>>(
          selector: (_, model) => model.filteredRoutes,
          builder: (context, _routes, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(worldData.name ?? ""),
              ),
              body: ExpandableTheme(
                data: const ExpandableThemeData(
                  iconColor: zdvMidBlue,
                  useInkWell: true,
                ),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _routes.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return ExpandingCard(_routes[index]);
                    }),
              ),
            );
          });
    });
  }
}

class ExpandingCard extends StatefulWidget {
  final RouteData _routeData;

  ExpandingCard(this._routeData);

  @override
  _ExpandingCardState createState() => _ExpandingCardState();
}

class _ExpandingCardState extends State<ExpandingCard> {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
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
                    padding: EdgeInsets.all(10),
                    child: Text(
                      widget._routeData.routeName ?? "",
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
                    iconLineItem('Route Details', Icon(Icons.arrow_forward_ios),
                        widget._routeData.url ?? "NA"),
                    // routeProfile(),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
    final List<Widget> _painters = <Widget>[];

    String url = 'https://zwifthacks.com/app/routes/svg/route/?world=' +
        worldId.toString() +
        '&route=' +
        routeId.toString() +
        '&showprofile=1&showlegend=1';

    List<String> uriNames = <String>[url];

    for (String uriName in uriNames) {
      _painters.add(
        SvgPicture.network(
          uriName,
          placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator()),
        ),
      );
    }

    return _painters;
  }

  Widget routeLineItem(String title, String value) {
    return Container(
        height: rowHeight,
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Constants.headerTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              Text(
                value,
                style: Constants.bodyTextStyle,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ));
  }

  Widget eventLineItem(String title, RouteData routeData) {
    return Container(
        height: rowHeight,
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Constants.headerTextStyle,
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
                  Provider.of<RouteDataModel>(context, listen: false)
                      .updateRouteData();
                },
                activeTrackColor: zdvmLgtBlue,
                activeColor: zdvmMidBlue[100],
              ), //),
            ],
          ),
        ));
  }

  Widget iconLineItem(String title, Icon value, String url) {
    return Container(
        height: rowHeight,
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Constants.headerTextStyle,
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
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
