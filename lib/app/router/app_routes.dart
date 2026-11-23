/// Named route paths of the application.
abstract final class AppRoutes {
  static const home = '/';
  static const transactions = '/transactions';
  static const transactionAdd = '/transactions/add';
  static const transactionEdit = '/transactions/edit/:id';
  static const transactionDetails = '/transactions/details/:id';

  /// Builds the concrete edit path for [id].
  static String editTransaction(String id) => '/transactions/edit/$id';

  /// Builds the concrete details path for [id].
  static String transactionDetailsPath(String id) =>
      '/transactions/details/$id';
}
