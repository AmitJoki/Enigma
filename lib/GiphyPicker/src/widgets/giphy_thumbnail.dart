import 'dart:typed_data';

import 'package:Enigma/GiphyPicker/src/model/giphy_repository.dart';
import 'package:flutter/material.dart';

/// Loads and renders a gif thumbnail image using a GiphyRepostory and an index.
class GiphyThumbnail extends StatefulWidget {
  final GiphyRepository repo;
  final int index;
  final Widget placeholder;

  const GiphyThumbnail(
      {Key key, @required this.repo, @required this.index, this.placeholder})
      : super(key: key);

  @override
  _GiphyThumbnailState createState() => _GiphyThumbnailState();
}

class _GiphyThumbnailState extends State<GiphyThumbnail> {
  Future<Uint8List> _loadPreview;

  @override
  void initState() {
    _loadPreview = widget.repo.getPreview(widget.index);
    super.initState();
  }

  @override
  void dispose() {
    widget.repo.cancelGetPreview(widget.index);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _loadPreview,
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (!snapshot.hasData) {
          return widget.placeholder ?? Container(color: Colors.grey.shade200);
        }
        return Image.memory(snapshot.data, fit: BoxFit.cover);
      });
}
