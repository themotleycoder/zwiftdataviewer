import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ConfigData? _configData;
  late String val;

  @override
  void initState() {
    super.initState();
    _configData =
        Provider.of<ConfigDataModel>(context, listen: false).configData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(children: [
          createCard(
              'FTP',
              Expanded(
                  child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextField(
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _configData?.ftp?.toString() ?? '100',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _configData!.ftp = int.parse(value);
                        print(_configData!.ftp);
                      });
                      Provider.of<ConfigDataModel>(context, listen: false)
                          .configData = _configData;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]),
                // ],
              ))),
          createCard(
            'Metric',
            Switch(
              value: _configData!.isMetric!,
              onChanged: (value) {
                setState(() {
                  _configData!.isMetric = value;
                  print(_configData!.isMetric);
                });
                Provider.of<ConfigDataModel>(context, listen: false)
                    .configData = _configData;
              },
              activeTrackColor: zdvmLgtBlue,
              activeColor: zdvmMidBlue[100],
            ),
          ),
          createCard(
              'Refresh Route Data',
              IconButton(
                  key: AppKeys.refreshButton,
                  tooltip: 'refresh',
                  icon: Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshRouteData())),
          createCard(
              'Refresh Calendar Data',
              IconButton(
                  key: AppKeys.refreshButton,
                  tooltip: 'refresh',
                  icon: Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshCalendarData())),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }

  refreshRouteData() {
    new FileRepository().scrapeRouteData();
  }

  refreshCalendarData() {
    new FileRepository().scrapeWorldCalendarData();
  }

  Card createCard(String label, Widget widget) {
    return Card(
        elevation: 0,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            child: Text(label, style: Constants.headerTextStyle),
            margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
          widget
        ]));
  }
}
