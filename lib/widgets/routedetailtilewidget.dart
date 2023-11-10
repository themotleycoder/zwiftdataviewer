import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

double rowHeight = 40;

class RouteDetailTile extends ConsumerWidget {
  final RouteData _routeData;

  const RouteDetailTile(this._routeData, {super.key});

  // @override
  // ConsumerState<ConsumerStatefulWidget> createState() {
  //   // TODO: implement createState
  //   throw UnimplementedError();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    String routeName =
        "${_routeData.world}: ${_routeData.routeName}";
    if (_routeData.eventOnly == "Event Only") {
      routeName = "$routeName (Event Only)";
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 8.0),
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Center(
        child: InkWell(
            child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(constants.roundedCornerSize),
          ),
          tileColor: constants.tileBackgroundColor,
          // leading: const Icon(Icons.directions_bike,
          //     size: 32.0, color: zdvOrange),
          title: Text(routeName,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: constants.headerFontStyle),
          subtitle: Column(children: [
            Row(children: [
              const Icon(Icons.route, color: zdvMidBlue, size: 30),
              Text(" ${Conversions.metersToDistance(
                  ref, _routeData.distanceMeters!)
                  .toStringAsFixed(1)}${units['distance']}")
            ]),
            Row(children: [
              const Icon(Icons.filter_hdr, color: zdvMidBlue, size: 30),
              Text(" ${Conversions.metersToHeight(
                  ref, _routeData.altitudeMeters!)
                  .toStringAsFixed(1)}${units['height']}")
            ])
          ]),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: zdvMidBlue,
          ),
          onTap: () {
            launchURL(_routeData.url ?? "NA");
          },
        )),
        // )
      ),
    );
  }

  // routeProfile() {}

  // List<Widget> loadMapImage(int worldId, int routeId) {
  //   final List<Widget> painters = <Widget>[];
  //
  //   String url =
  //       'https://zwifthacks.com/app/routes/svg/route/?world=$worldId&route=$routeId&showprofile=1&showlegend=1';
  //
  //   List<String> uriNames = <String>[url];
  //
  //   for (String uriName in uriNames) {
  //     painters.add(
  //       SvgPicture.network(
  //         uriName,
  //         placeholderBuilder: (BuildContext context) => Container(
  //             padding: const EdgeInsets.all(30.0),
  //             child: const CircularProgressIndicator()),
  //       ),
  //     );
  //   }
  //
  //   return painters;
  // }
  //
  // Widget routeLineItem(String title, String value) {
  //   return SizedBox(
  //       height: rowHeight,
  //       child: Padding(
  //         padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: constants.headerTextStyle,
  //               softWrap: true,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             Text(
  //               value,
  //               style: constants.bodyTextStyle,
  //               softWrap: true,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ],
  //         ),
  //       ));
  // }
  //
  // Widget eventLineItem(String title, RouteData routeData) {
  //   return SizedBox(
  //       height: rowHeight,
  //       child: Padding(
  //         padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: constants.headerTextStyle,
  //               softWrap: true,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             // Container(
  //             //     height: 50,
  //             Switch(
  //               value: routeData.completed ?? false,
  //               onChanged: (value) {
  //                 routeData.completed = value;
  //                 setState(() {});
  //                 // Provider.of<RouteDataModel>(context, listen: false)
  //                 //     .updateRouteData();
  //               },
  //               activeTrackColor: zdvmLgtBlue,
  //               activeColor: zdvmMidBlue[100],
  //             ), //),
  //           ],
  //         ),
  //       ));
  // }
  //
  // Widget iconLineItem(String title, Icon value, String url) {
  //   return SizedBox(
  //       height: rowHeight,
  //       child: Padding(
  //         padding: const EdgeInsets.only(left: 0, right: 0, bottom: 16),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: constants.headerTextStyle,
  //               softWrap: true,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             IconButton(
  //               icon: value,
  //               color: zdvmMidBlue[100],
  //               onPressed: () => launchURL(url),
  //             ),
  //           ],
  //         ),
  //       ));
  // }

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
