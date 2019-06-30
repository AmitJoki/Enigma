import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:Enigma/GiphyPicker/giphy_picker.dart';

/// Provides the context for a Giphy search operation, and makes its data available to its widget sub-tree.
class GiphyContext extends InheritedWidget {
  final String apiKey;
  final String rating;
  final String language;
  final ValueChanged<GiphyGif> onSelected;
  final ErrorListener onError;

  const GiphyContext(
      {Key key,
      @required Widget child,
      @required this.apiKey,
      this.rating = GiphyRating.g,
      this.language = GiphyLanguage.english,
      this.onSelected,
      this.onError})
      : super(key: key, child: child);

  void select(GiphyGif gif) {
    if (onSelected != null) {
      onSelected(gif);
    }
  }

  void error(dynamic error) {
    if (onError != null) {
      onError(error);
    }
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static GiphyContext of(BuildContext context) {
    final settings = context
        .ancestorInheritedElementForWidgetOfExactType(GiphyContext)
        ?.widget as GiphyContext;

    if (settings == null) {
      throw 'Required GiphyContext widget not found. Make sure to wrap your widget with GiphyContext.';
    }
    return settings;
  }
}
