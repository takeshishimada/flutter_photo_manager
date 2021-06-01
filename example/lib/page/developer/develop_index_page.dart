import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_scanner_example/page/developer/create_entity_by_id.dart';
import 'package:photo_manager/photo_manager.dart';

import 'dev_title_page.dart';
import 'ios/create_folder_example.dart';
import 'ios/edit_asset.dart';
import 'remove_all_android_not_exists_example.dart';

class DeveloperIndexPage extends StatefulWidget {
  @override
  _DeveloperIndexPageState createState() => _DeveloperIndexPageState();
}

class _DeveloperIndexPageState extends State<DeveloperIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("develop index"),
      ),
      body: ListView(
        children: <Widget>[
          ElevatedButton(
            child: Text("Show iOS create folder example."),
            onPressed: () => navToWidget(CreateFolderExample()),
          ),
          ElevatedButton(
            child: Text("Test edit image"),
            onPressed: () => navToWidget(EditAssetPage()),
          ),
          ElevatedButton(
            child: Text("Show Android remove not exists asset example."),
            onPressed: () => navToWidget(RemoveAndroidNotExistsExample()),
          ),
          ElevatedButton(
            child: Text("upload file to local to test EXIF."),
            onPressed: _upload,
          ),
          ElevatedButton(
            child: Text("Save video to photos."),
            onPressed: _saveVideo,
          ),
          ElevatedButton(
            child: Text("Open test title page"),
            onPressed: _navigatorSpeedOfTitle,
          ),
          ElevatedButton(
            child: Text("Open setting."),
            onPressed: _openSetting,
          ),
          ElevatedButton(
            child: Text("Create Entity ById"),
            onPressed: () => navToWidget(CreateEntityById()),
          ),
          ElevatedButton(
            child: Text("Clear file caches"),
            onPressed: _clearFileCaches,
          ),
          ElevatedButton(
            child: Text("Request permission extend"),
            onPressed: _requestPermssionExtend,
          ),
          ElevatedButton(
            child: Text("PresentLimited"),
            onPressed: _persentLimited,
          ),
          ElevatedButton(
            child: Text("getRecentPath"),
            onPressed: getRecentPathExample,
          ),
          ElevatedButton(
            child: Text("firstLoad"),
            onPressed: _firstLoadExample,
          ),
        ],
      ),
    );
  }

  void _upload() async {
    final path = await PhotoManager.getAssetPathList(type: RequestType.image);
    final assetList = await path[0].getAssetListRange(start: 0, end: 5);
    final asset = assetList[0];

    // for (final tmpAsset in assetList) {
    //   await tmpAsset.originFile;
    // }

    final file = await asset.originFile;
    if (file == null) {
      return;
    }

    print("file length = ${file.lengthSync()}");

    http.Client client = http.Client();
    final req = http.MultipartRequest(
      "post",
      Uri.parse("http://172.16.100.7:10001/upload/file"),
    );

    req.files
        .add(await http.MultipartFile.fromPath("file", file.absolute.path));

    req.fields["type"] = "jpg";

    final response = await client.send(req);
    final body = await utf8.decodeStream(response.stream);
    print(body);
  }

  void _saveVideo() async {
    // String url = "http://172.16.100.7:5000/QQ20181114-131742-HD.mp4";
    String url =
        "http://172.16.100.7:5000/Kapture%202019-11-20%20at%2017.07.58.mp4";

    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(url));
    final resp = await req.close();
    final tmp = Directory.systemTemp;
    final title = "${DateTime.now().millisecondsSinceEpoch}.mp4";
    final f = File("${tmp.absolute.path}/$title");
    if (f.existsSync()) {
      f.deleteSync();
    }
    f.createSync();

    resp.listen((data) {
      f.writeAsBytesSync(data, mode: FileMode.append);
    }, onDone: () async {
      client.close();
      print("the video file length = ${f.lengthSync()}");
      final result = await PhotoManager.editor.saveVideo(f, title: title);
      if (result != null) {
        print("result : ${(await result.originFile)?.path}");
      } else {
        print("result is null");
      }
    });
  }

  void _navigatorSpeedOfTitle() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      final widget = DevelopingExample();
      return widget;
    }));
  }

  void navToWidget(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return widget;
    }));
  }

  void _openSetting() {
    PhotoManager.openSetting();
  }

  void _clearFileCaches() {
    PhotoManager.clearFileCache();
  }

  void _requestPermssionExtend() async {
    final state = await PhotoManager.requestPermissionExtend();
    print('result --- state: $state');
  }

  Future<void> _persentLimited() async {
    await PhotoManager.presentLimited();
  }

  Future<void> getRecentPathExample() async {
    final watch = Stopwatch();
    watch.start();
    final recent = await PhotoManager.getRecentPath();
    print(
        'path.count = ${recent.count}, timeout: ${watch.elapsedMilliseconds}');

    final totalWatch = Stopwatch();
    print('Test by page');
    totalWatch.start();

    for (var pageIndex = 0, pageCount = 300;
        pageIndex < recent.count / pageCount;
        pageIndex++) {
      watch.reset();
      final asset = await recent.getAssetByPage(
        page: pageIndex,
        count: pageCount,
      );

      print(
          'get page asset by page index: $pageIndex asset count: ${asset.length}, timeout: ${watch.elapsedMilliseconds}');
    }

    print(
        'The total of page index running delay: ${totalWatch.elapsedMilliseconds}');

    print('Test by index');
    totalWatch.reset();
    for (var startIndex = 0, count = 300;
        startIndex < recent.count;
        startIndex += count) {
      watch.reset();
      final asset = await recent.getAssetByIndex(
        startIndex: startIndex,
        count: count,
      );

      print(
          'start index: $startIndex asset count: ${asset.length}, timeout: ${watch.elapsedMilliseconds}');
    }
    print(
        'The total of start index running delay: ${totalWatch.elapsedMilliseconds}');
  }

  void _firstLoadExample() async {
    final sw = Stopwatch();
    sw.start();
    final pathList = await PhotoManager.getAssetPathList();
    print("load path list time: ${sw.elapsedMilliseconds}ms");

    final recent = pathList.firstWhere((element) => element.isAll);
    sw.reset();
    final firstScreen = await recent.getAssetListPaged(0, 300);
    final assetLength = firstScreen.length;
    print(
        'first screen load time: ${sw.elapsedMilliseconds}ms, count: $assetLength');
  }
}
