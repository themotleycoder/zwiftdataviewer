import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ConfigData configData = ConfigData();

    configData = ref.watch(configProvider);

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
                      hintText: configData.ftp?.toString() ?? '0',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      configData.ftp = double.parse(value);
                      ref.read(configProvider.notifier).setConfig(configData);

                      // setState(() {
                      //   _configData!.ftp = int.parse(value);
                      //   print(_configData!.ftp);
                      // });
                      // Provider.of<ConfigDataModel>(context, listen: false)
                      //     .configData = _configData;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]),
                // ],
              ))),
          createCard(
            'Metric',
            Switch(
              value: configData.isMetric!,
              onChanged: (value) {
                configData.isMetric = value;
                ref.read(configProvider.notifier).setConfig(configData);
                // setState(() {
                //   _configData!.isMetric = value;
                //   print(_configData!.isMetric);
                // });
                // Provider.of<ConfigDataModel>(context, listen: false)
                //     .configData = _configData;
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
                  icon: const Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshRouteData())),
          createCard(
              'Refresh Calendars Data',
              IconButton(
                  key: AppKeys.refreshButton,
                  tooltip: 'refresh',
                  icon: const Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshCalendarData())),
        ]));
  }

  refreshRouteData() {
    FileRepository().scrapeRouteData();
  }

  refreshCalendarData() {
    FileRepository().scrapeWorldCalendarData();
    FileRepository().scrapeClimbCalendarData();
  }

  Card createCard(String label, Widget widget) {
    return Card(
        elevation: defaultCardElevation,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(label, style: constants.headerTextStyle),
          ),
          widget
        ]));
  }
}
