import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/widgets/connectivity_status_widget.dart';

abstract class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(context, ref),
      drawer: buildDrawer(context, ref),
      body: Column(
        children: [
          // Add connectivity banner at the top of the screen
          const ConnectivityBanner(),

          // Main content
          Expanded(
            child: buildBody(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
    );
  }

  // String getTitle(WidgetRef ref);

  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;

  Widget buildBody(BuildContext context, WidgetRef ref);

  Widget? buildDrawer(BuildContext context, WidgetRef ref) => null;

  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) => null;

  int getTabIndex(WidgetRef ref);
}
