import 'dart:convert';

import 'package:flutter/services.dart';

Future<dynamic> fetchLocalJsonData(String fileName) async {
  final String json = await rootBundle.loadString('assets/' + fileName);
  final dynamic contents = jsonDecode(json);
  return contents;
}
