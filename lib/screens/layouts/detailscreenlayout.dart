import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

abstract class DetailScreenLayout extends ConsumerWidget {
  const DetailScreenLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
            title: Text(getTitle(ref)),
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
          child: getChildView(ref),
        ));
  }

  String getTitle(WidgetRef ref);

  getChildView(WidgetRef ref);
}
