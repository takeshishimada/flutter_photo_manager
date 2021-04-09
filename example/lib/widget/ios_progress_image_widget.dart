import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class IosProgressAssetWidget extends StatefulWidget {
  final AssetEntity entity;

  const IosProgressAssetWidget({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  _IosProgressAssetWidgetState createState() => _IosProgressAssetWidgetState();
}

class _IosProgressAssetWidgetState extends State<IosProgressAssetWidget> {
  ValueNotifier<Uint8List?> imageDataNotifier = ValueNotifier(null);
  Stream<PMProgressState>? stream;
  @override
  void initState() {
    super.initState();
    PMProgressHandler progressHandler = PMProgressHandler();
    stream = progressHandler.stream;
    widget.entity
        .thumbDataWithOption(ThumbOption.ios(width: 1000, height: 1000))
        .then((value) {
      imageDataNotifier.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = imageDataNotifier.value;
    if (bytes != null) {
      return Image.memory(bytes);
    }
    if (stream == null) {
      return Container();
    }
    return StreamBuilder<PMProgressState>(
      initialData: PMProgressState(0, PMRequestState.prepare),
      builder: _buildProgress,
    );
  }

  Widget _buildProgress(
    BuildContext context,
    AsyncSnapshot<PMProgressState> snapshot,
  ) {
    if (!snapshot.hasData) {
      return Container();
    }
    final progressState = snapshot.data!;
    final progress = progressState.progress;
    final state = progressState.state;

    return Text('state = $state, progress = $progress');
  }
}
