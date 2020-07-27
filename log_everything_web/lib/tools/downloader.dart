import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

typedef DownloadFunc<T> = Future<T> Function();

typedef KeyProvider<K, V> = V Function(K key);

class Cache<K, V> {
  final KeyProvider<K, V> keyProvider;
  final Map<K, V> _cache = {};

  Cache({@required this.keyProvider}) : assert(keyProvider != null);

  V get(K key) {
    V value = _cache[key];
    if (value != null) {
      return value;
    } else {
      value = keyProvider(key);
      _cache[key] = value;
      return value;
    }
  }
}

class Downloader<T> {
  final DownloadFunc<T> download;

  Downloader({@required this.download}) : assert(download != null);

  final _contentUpdates = PublishSubject<T>();

  Stream<T> get data async* {
    try {
      final data = await download();
      yield data;
    } catch (e) {
      print('Error: ${e.toString()}');
      rethrow;
    }
    await for (final update in _contentUpdates) {
      yield update;
    }
  }

  Future<T> refresh() async {
    final data = await download();
    _contentUpdates.add(data);
    return data;
  }
}
