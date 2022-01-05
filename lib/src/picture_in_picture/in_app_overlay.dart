import 'dart:async';

import 'package:flutter/material.dart';

const _defaultPosition = PIPDimensions(200, 100, 140, 400);

class PIPOverlayController {
  static OverlayEntry? _overlay;
  static PIPDimensions _position = _defaultPosition;
  static final StreamController<PIPDimensions> _dimensionsController = StreamController.broadcast()..add(_position);
  static Stream<PIPDimensions> get dimensions => _dimensionsController.stream.map((d) {
        _position += d;
        return _position;
      });

  static void enterAppPIPMode(
    BuildContext context,
    Widget videoView,
  ) {
    _overlay = OverlayEntry(builder: (context) => PIPOverlay(videoView: videoView));
    Overlay.of(context)?.insert(_overlay!);
  }

  static void dragView(double changeX, double changeY) {
    _dimensionsController.add(PIPDimensions(0, 0, changeX, changeY));
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
          d = d.copyWith(width: size.width, height: size.height, x: 0, y: 0);
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

  const PIPDimensions(this.width, this.height, this.x, this.y, {this.fullscreen = false});

  PIPDimensions enterFullscreen() => copyWith(width: 0, height: 0, x: 0, y: 0, fullscreen: true);
  PIPDimensions exitFullscreen() => copyWith(width: 0, height: 0, x: 0, y: 0, fullscreen: false);

  PIPDimensions copyWith({double? width, double? height, double? x, double? y, bool? fullscreen}) => PIPDimensions(
        width ?? this.width,
        height ?? this.height,
        y ?? this.y,
        x ?? this.x,
        fullscreen: fullscreen ?? this.fullscreen,
      );

  PIPDimensions operator +(PIPDimensions d) => PIPDimensions(
        width + d.width,
        height + d.height,
        x + d.x,
        y + d.y,
        fullscreen: d.fullscreen,
      );

  @override
  String toString() => 'width: $width, height: $height, x: $x, y: $y';
}
