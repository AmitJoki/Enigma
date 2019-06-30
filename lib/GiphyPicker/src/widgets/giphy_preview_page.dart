import 'package:Enigma/GiphyPicker/src/widgets/giphy_image.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:Enigma/const.dart';

/// Presents a Giphy preview image.
class GiphyPreviewPage extends StatelessWidget {
  final GiphyGif gif;
  final Widget title;
  final ValueChanged<GiphyGif> onSelected;

  const GiphyPreviewPage(
      {@required this.gif, @required this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: EnigmaTheme,
        child: Scaffold(
            appBar: AppBar(title: title, actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.check), onPressed: () {
                    onSelected(gif);
                    Navigator.pop(context);
                  })
            ]),
            body: SafeArea(
                child: Center(child: GiphyImage.original(gif: gif)),
                bottom: false)));
  }
}
