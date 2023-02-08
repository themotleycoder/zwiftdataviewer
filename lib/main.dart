import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/mainapp.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ZwiftViewerApp(
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
  ));
}
