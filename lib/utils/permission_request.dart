import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission is granted, proceed with download
  } else if (status.isDenied) {
    // Handle denied permission
  } else if (status.isPermanentlyDenied) {
    // Open app settings to allow the user to grant permission manually
    openAppSettings();
  }
}
