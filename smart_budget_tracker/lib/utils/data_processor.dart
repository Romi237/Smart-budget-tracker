class DataProcessor<T> {
  void processList(List<T> items, Function(T) action) {
    for (var item in items) {
      action(item);
    }
  }
}
