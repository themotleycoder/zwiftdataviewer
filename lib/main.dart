import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/mainapp.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child:ZwiftViewerApp(
    configRepository: FileRepository(),
    // configRepository: LocalStorageRepository(
    //     configStorage: FileStorage(), localStorage: FileStorage()),
    // activitiesRepository: LocalStorageRepository(
    //     configStorage: FileStorage(), localStorage: FileStorage()),
    // repository: LocalStorageRepository(
    //   localStorage: KeyValueStorage(
    //     'change_notifier_provider_todos',
    //     FlutterKeyValueStore(await SharedPreferences.getInstance()),
    //   ),
    // ),
  )));
}
