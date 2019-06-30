import 'package:Enigma/GiphyPicker/src/widgets/giphy_search_view.dart';
import 'package:Enigma/const.dart';
import 'package:flutter/material.dart';

class GiphySearchPage extends StatelessWidget {
  final Widget title;

  const GiphySearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: EnigmaTheme,
        child: Scaffold(
            appBar: AppBar(title: Image.asset('assets/giphy.png')),
            body: SafeArea(child: GiphySearchView(), bottom: false)));
  }
}
