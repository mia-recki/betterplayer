import 'dart:async';

import 'package:flutter/material.dart';

const _defaultPosition = PIPDimensions(width: 200, height: 100, x: 140, y: 400);

class PIPOverlayController {
  // keep track of current overlay widget
  static OverlayEntry? _overlay;

  // position on the screen of in-app pip widget
  static PIPDimensions _position = _defaultPosition;

  // takes updates from `GestureDetector` and adds them to the stream
  static final StreamController<PIPDimensions> _dimensionsController = StreamController.broadcast()..add(_position);

  /// tracks the current position of pip video widget
  static Stream<PIPDimensions> get dimensions => _dimensionsController.stream.map((d) {
        _position += d;
        return _position;
      });

  static void enterAppPIPMode(
    BuildContext context,
    Widget videoView,
  ) {
    removeOverlay();
    _overlay = OverlayEntry(builder: (context) => PIPOverlay(videoView: videoView));
    Overlay.of(context)?.insert(_overlay!);
  }

  static void dragView(double changeX, double changeY) {
    _dimensionsController.add(PIPDimensions(width: 0, height: 0, x: changeX, y: changeY));
  }

  static void removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }
}

class PIPOverlay extends StatelessWidget {
  const PIPOverlay({required this.videoView, Key? key}) : super(key: key);

  final Widget videoView;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PIPDimensions>(
      stream: PIPOverlayController.dimensions,
      builder: (context, snapshot) {
        PIPDimensions d = snapshot.data ?? _defaultPosition;
        if (d.fullscreen) {
          final size = MediaQuery.of(context).size;
          d = PIPDimensions(width: size.width, height: size.height, x: 0, y: 0, fullscreen: d.fullscreen);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: d.x,
              top: d.y,
              width: d.width,
              height: d.height,
              child: GestureDetector(
                onPanUpdate: (details) {
                  PIPOverlayController.dragView(details.delta.dx, details.delta.dy);
                },
                child: videoView,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PIPDimensions {
  final double width;
  final double height;
  final double x;
  final double y;
  final bool fullscreen;

  const PIPDimensions({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.fullscreen = false,
  });

  PIPDimensions enterFullscreen() => PIPDimensions(width: 0, height: 0, x: 0, y: 0, fullscreen: true);
  PIPDimensions exitFullscreen() => PIPDimensions(width: 0, height: 0, x: 0, y: 0, fullscreen: false);

  PIPDimensions operator +(PIPDimensions d) => PIPDimensions(
        width: width + d.width,
        height: height + d.height,
        x: x + d.x,
        y: y + d.y,
        fullscreen: d.fullscreen,
      );

  @override
  String toString() => 'width: $width, height: $height, x: $x, y: $y';
}
