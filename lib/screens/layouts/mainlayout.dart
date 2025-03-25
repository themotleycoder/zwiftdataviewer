import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class MainLayout extends ConsumerWidget {
  MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: Stack(children: [Container(child: buildBody(context, ref))]),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
    );
  }

  // String getTitle(WidgetRef ref);

  buildAppBar(BuildContext context, WidgetRef ref){}

  buildBody(BuildContext context, WidgetRef ref);

  buildBottomNavigationBar(BuildContext context, WidgetRef ref);

  getTabIndex(WidgetRef ref);
}
