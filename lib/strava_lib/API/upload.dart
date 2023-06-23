// Upload file

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/fault.dart';
import '../Models/uploadActivity.dart';
import '../errorCodes.dart' as error;
import '../globals.dart' as globals;

abstract class Upload {
  /// Tested with gpx and tcx
  /// For the moment the parameters
  ///
  /// trainer and commute are set to false
  ///
  /// statusCode:
  /// 201 activity created
  /// 400 problem could be that activity already uploaded
  ///
  Future<Fault> uploadActivity(
      String name, String description, String fileUrl, String fileType) async {
    globals.displayInfo('Starting to upload activity');

    // To check if the activity has been uploaded successfully
    // No numeric error code for the moment given by Strava
    const String ready = "Your activity is ready.";
    const String deleted = "The created activity has been deleted.";
    const String errorMsg = "There was an error processing your activity.";
    const String processed = "Your activity is still being processed.";
    const String notFound = 'Not Found';

    final postUri = Uri.parse('https://www.strava.com/api/v3/uploads');
    StreamController<int> onUploadPending = StreamController();

    var fault = Fault(888, '');

    var request = http.MultipartRequest("POST", postUri);
    request.fields['data_type'] = fileType; // tested with gpx
    request.fields['trainer'] = 'false';
    request.fields['commute'] = 'false';
    request.fields['name'] = name;
    request.fields['external_id'] = 'strava_flutter';
    request.fields['description'] = description;

    var header = globals.createHeader();

    if (header.containsKey('88') == true) {
      globals.displayInfo('Token not yet known');
      fault = Fault(error.statusTokenNotKnownYet, 'Token not yet known');
      return fault;
    }

    request.headers.addAll(header);

    request.files.add(await http.MultipartFile.fromPath('file', fileUrl));
    globals.displayInfo(request.toString());

    var response = await request.send();

    globals.displayInfo(
        'Response: ${response.statusCode} ${response.reasonPhrase}');

    fault.statusCode = response.statusCode;
    fault.message = response.reasonPhrase!;

    if (response.statusCode != 201) {
      globals.displayInfo('Error while uploading the activity');
      globals.displayInfo('${response.statusCode} - ${response.reasonPhrase}');
    }

    int idUpload;

    // Upload is processed by the server
    // now wait for the upload to be finished
    //----------------------------------------
    if (response.statusCode == 201) {
      globals.displayInfo('Activity successfully created');
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        final Map<String, dynamic> body = json.decode(value);
        ResponseUploadActivity response0 =
            ResponseUploadActivity.fromJson(body);

        print('id ${response0.id}');
        idUpload = response0.id!;
        onUploadPending.add(idUpload);
      });

      String reqCheckUpgrade = 'https://www.strava.com/api/v3/uploads/';
      onUploadPending.stream.listen((id) async {
        reqCheckUpgrade = reqCheckUpgrade + id.toString();
        var resp = await http.get(Uri.parse(reqCheckUpgrade), headers: header);
        print('check status ${resp.reasonPhrase}  ${resp.statusCode}');

        // Everything is fine the file has been loaded
        if (resp.statusCode == 200) {
          print('200 ${resp.reasonPhrase}');
        }

        // 404 the temp id does not exist anymore
        // Activity has been probably already loaded
        if (resp.statusCode == 404) {
          print('---> 404 activity already loaded  ${resp.reasonPhrase}');
        }

        if (resp.reasonPhrase?.compareTo(ready) == 0) {
          print('---> Activity succesfully uploaded');
          onUploadPending.close();
        }

        if ((resp.reasonPhrase?.compareTo(notFound) == 0) ||
            (resp.reasonPhrase?.compareTo(errorMsg) == 0)) {
          print('---> Error while checking status upload');
          onUploadPending.close();
        }

        if (resp.reasonPhrase?.compareTo(deleted) == 0) {
          print('---> Activity deleted');
          onUploadPending.close();
        }

        if (resp.reasonPhrase?.compareTo(processed) == 0) {
          print('---> try another time');
          // wait 2 sec before checking again status
          Timer(const Duration(seconds: 2), () => onUploadPending.add(id));
        }
      });
    }

    return fault;
  }
}
