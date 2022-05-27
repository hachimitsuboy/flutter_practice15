import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _deviceInfo;

  @override
  void initState() {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    Future(() async {
      deviceInfo = await _getDeviceInfo(deviceInfo);
    });

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("デバイス名: $_deviceInfo"),
      ),
      body: FutureBuilder<PackageInfo>(
        future: _getInfo(),
        builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("エラーが発生しました"));
          } else if (!snapshot.hasData) {
            return const Text("Loading...");
          }
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text("アプリ名: ${snapshot.data!.appName}"),
                Text("パッケージ名: ${snapshot.data!.packageName}"),
                Text("バージョン: ${snapshot.data!.packageName}"),
                Text("ビルドNo: ${snapshot.data!.buildNumber}"),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () => _openCamera(context),
                  child: const Text("カメラ"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<PackageInfo> _getInfo() {
    return PackageInfo.fromPlatform();
  }

  _getDeviceInfo(DeviceInfoPlugin deviceInfo) async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo.model);

    _deviceInfo = androidInfo.model;
  }

  _openCamera(BuildContext context) async {
    // openAppSettings();

    var status = await Permission.camera.status;
    print(status);

    if (status.isDenied) {
      _showRequestDialog(context);
      // Either the permission was already granted before or the user just granted it.
    }

  }

  void _showRequestDialog(BuildContext context) async {
    await showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("カメラの利用には許可が必要です"),
        content: const Text("カメラの利用を許可しますか？"),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(onPressed: () => openAppSettings(), child: const Text("許可")),
        ],
      );
    });
  }
}
