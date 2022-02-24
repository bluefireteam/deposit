/// Sort data by [key] in ascending or descending order.
class OrderBy {
  /// Sort data by given [key].
  ///
  /// By passing [ascending] you can change the order.
  OrderBy(this.key, {this.ascending = false});

  /// Key to order by.
  final String key;

  /// Order direction.
  final bool ascending;
}
