import 'dart:async';
import 'dart:collection';

import 'package:Enigma/GiphyPicker/giphy_picker.dart';

/// A general-purpose repository with support for on-demand paged retrieval and caching of values of type T.
abstract class Repository<T> {
  final HashMap<int, T> _cache = HashMap<int, T>();
  final Set<int> _pagesLoading = Set<int>();
  final HashMap<int, Completer<T>> _completers = HashMap<int, Completer<T>>();
  final int pageSize;
  final ErrorListener onError;
  int _totalCount;

  Repository({this.pageSize, this.onError}) {
    assert(pageSize != null);
    assert(onError != null);
  }

  /// The total number of values available.
  int get totalCount => _totalCount;

  /// Asynchronously retrieves the value at specified index. When not available in local cache
  /// the page containing the value is retrieved.
  Future<T> get(int index) {
    assert(index != null);
    // index must within bounds, or 0 if totalCount is null
    assert(
        _totalCount == null && index == 0 || index >= 0 && index < _totalCount);

    final value = _cache[index];

    // value is availableÍ
    if (value != null) {
      return Future.value(value);
    }

    final page = index ~/ pageSize;

    // value is not available, retrieve page
    if (!_pagesLoading.contains(page)) {
      _pagesLoading.add(page);
      final future = getPage(page);
      future.then((page) => _onGetPage(page)).catchError(onError);
    }

    // value is being retrieved
    var completer = _completers[index];
    if (completer == null) {
      completer = Completer<T>();
      _completers[index] = completer;
    }

    return completer.future;
  }

  void _onGetPage(Page<T> page) {
    _pagesLoading.remove(page);
    _totalCount = page.totalCount;

    if (_totalCount == 0) {
      // complete all with null
      _completers.values.forEach((c) => c.complete(null));
      _completers.clear();
    } else {
      for (var i = 0; i < page.values.length; i++) {
        // store value
        final index = page.page * pageSize + i;
        final value = page.values[i];
        _cache[index] = value;

        // complete optional completer
        final completer = _completers.remove(index);
        completer?.complete(value);
      }
    }
  }

  Future<Page<T>> getPage(int page);
}

/// Represents a page of values.
class Page<T> {
  final List<T> values;
  final int page;
  final int totalCount;

  const Page(this.values, this.page, this.totalCount);
}
