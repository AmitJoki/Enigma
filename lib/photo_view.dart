import 'package:Enigma/open_settings.dart';
import 'package:Enigma/utils.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:Enigma/save.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoViewWrapper extends StatelessWidget {
  const PhotoViewWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      @required this.tag});

  final String tag;
  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Enigma.getNTPWrappedWidget(Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Enigma.checkAndRequestPermission(PermissionGroup.storage)
                .then((res) {
              if (res) {
                Save.saveToDisk(imageProvider, tag);
                Enigma.toast('Saved!');
              } else {
                Enigma.showRationale(
                    'Permission to access storage needed to save photos to your phone.');
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => OpenSettings()));
              }
            });
          },
          child: Icon(Icons.file_download),
        ),
        body: Container(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              imageProvider: imageProvider,
              loadingChild: loadingChild,
              backgroundDecoration: backgroundDecoration,
              minScale: minScale,
              maxScale: maxScale,
              heroTag: tag,
            ))));
  }
}
