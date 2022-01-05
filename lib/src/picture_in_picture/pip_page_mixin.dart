import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

// TODO: @optionalTypeArgs ?

mixin PIPPage<T extends StatefulWidget> on State<T> {
  BetterPlayerController get betterPlayerController;
  GlobalKey get playerKey;
  Function(BuildContext, BetterPlayerController) get rebuildPage;

  bool isInAppPIP = false;

  bool _isScreenDismissed = false;

  void enterPIP() {
    setState(() => isInAppPIP = true);
    PIPOverlayController.enterAppPIPMode(
      context,
      Stack(
        children: [
          BetterPlayer(
            controller: betterPlayerController,
            key: playerKey,
          ),
          OutlinedButton(
            onPressed: () => reopen(),
            child: const Text('reopen'),
          ),
        ],
      ),
    );
  }

  void reopen() {
    PIPOverlayController.removeOverlay();
    if (_isScreenDismissed) {
      final currentContext = playerKey.currentContext;
      if (currentContext != null) {
        rebuildPage(currentContext, betterPlayerController);
      }
    } else {
      setState(() => isInAppPIP = false);
    }
  }

  @override
  void initState() {
    PIPOverlayController.removeOverlay();
    betterPlayerController.addEventsListener((p0) => print(p0.betterPlayerEventType));
    super.initState();
  }

  @override
  void dispose() {
    _isScreenDismissed = true;
    super.dispose();
  }
}
