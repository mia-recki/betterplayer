import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

class PictureInPicturePage extends StatefulWidget {
  final GlobalKey globalKey;
  final BetterPlayerController? pipPlayer;

  const PictureInPicturePage(this.globalKey, {this.pipPlayer, Key? key}) : super(key: key);
  @override
  _PictureInPicturePageState createState() => _PictureInPicturePageState();
}

class _PictureInPicturePageState extends State<PictureInPicturePage> with PIPPage {
  @override
  late BetterPlayerController betterPlayerController;

  @override
  GlobalKey<State<StatefulWidget>> get playerKey => widget.globalKey;

  @override
  Function(BuildContext, BetterPlayerController) get rebuildPage => (context, controller) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => PictureInPicturePage(
              playerKey,
              pipPlayer: controller,
            ),
          ),
        );
      };

  final pipControlsConfiguration = BetterPlayerControlsConfiguration(
    enablePlayPause: true,
    enablePip: true,
    enableSkips: true,
    enableMute: false,
    enableRetry: false,
  );

  @override
  void initState() {
    if (widget.pipPlayer == null) {
      BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        Constants.elephantDreamVideoUrl,
      );
      betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
      betterPlayerController.setupDataSource(dataSource);
      betterPlayerController.setBetterPlayerGlobalKey(playerKey);
    } else {
      betterPlayerController = widget.pipPlayer!;
      betterPlayerController.setBetterPlayerControlsConfiguration(BetterPlayerControlsConfiguration());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Picture in Picture player"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Example which shows how to use PiP.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          if (!isInAppPIP)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: betterPlayerController,
                key: widget.globalKey,
              ),
            ),
          ElevatedButton(
            child: Text("Show PiP"),
            onPressed: () {
              betterPlayerController.setBetterPlayerControlsConfiguration(pipControlsConfiguration);
              enterPIP();
            },
          ),
          ElevatedButton(
            child: Text("Disable PiP"),
            onPressed: () async {
              betterPlayerController.disablePictureInPicture();
            },
          ),
        ],
      ),
    );
  }
}
