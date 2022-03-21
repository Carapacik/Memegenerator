import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListReactiveRepository<T> {
  final updater = PublishSubject<Null>();

  @protected
  Future<List<String>> getRawData();

  @protected
  Future<bool> saveRawData(final List<String> items);

  @protected
  T convertFromString(final String rawItem);

  @protected
  String convertToString(final T item);

  Future<List<T>> getItems() async {
    final rawItems = await getRawData();
    return rawItems.map(convertFromString).toList();
  }

  Future<bool> setItems(final List<T> items) async {
    final rawItems = items.map(convertToString).toList();
    return _setRawItems(rawItems);
  }

  Stream<List<T>> observeItems() async* {
    yield await getItems();
    await for (final _ in updater) {
      yield await getItems();
    }
  }

  Future<bool> addItem(final T newItem) async {
    final items = await getItems();
    items.add(newItem);
    return setItems(items);
  }

  Future<bool> removeItem(final T item) async {
    final items = await getItems();
    items.remove(item);
    return setItems(items);
  }

  Future<bool> _setRawItems(final List<String> rawItems) {
    updater.add(null);
    return saveRawData(rawItems);
  }
}
