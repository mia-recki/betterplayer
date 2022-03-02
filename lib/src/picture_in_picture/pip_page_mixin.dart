import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

// TODO: @optionalTypeArgs ?
// TODO: The state of this page continues to live even after the page itself has been killed -> not the cleanest solution

mixin PIPPage<T extends StatefulWidget> on State<T> {
  /// The controller that is in charge of playing the video that can go into Picture in Picture mode
  BetterPlayerController get betterPlayerController;

  /// Global key that is assigned to the BetterPlayerController
  GlobalKey get playerKey;

  /// A callback that gets triggered when the user tries to return to the full size video from PIP mode
  Function(BuildContext, BetterPlayerController) get rebuildPage;

  /// Keeps track of whether the video is playing in PIP mode. It's meant to be used to hide the full size
  /// player view while the video is being minimized
  bool isInAppPIP = false;

  // keeps track of whether the page is still alive (i.e., user hasn't dismissed it by going back)
  // or if the page needs to be fully rebuilt when exiting PIP mode
  bool _isScreenDismissed = false;

  /// Starts in-app PIP mode: an overlay is placed in the bottom right of the screen
  /// simultaneously, your page gets notified that the main player view can be hidden
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

  /// Removes the overlay player and rebuilds the page if the page is no longer active
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
    // register a callback that starts the native Android PIP mode when the user
    // wants to exit the app (e.g., presses the home button)
    betterPlayerController.videoPlayerController?.registerUserLeaveHintCallback(() {
      if (Platform.isAndroid) {
        // enter fullscreen mode + make Activity enter PIP mode
        betterPlayerController.enablePictureInPicture(playerKey);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _isScreenDismissed = true;
    super.dispose();
  }
}
