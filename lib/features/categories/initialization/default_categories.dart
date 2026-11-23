import '../../../core/enums/transaction_type.dart';
import '../data/models/category_seed.dart';

/// First-run category definitions.
abstract final class DefaultCategories {
  static const List<CategorySeed> seeds = [
    CategorySeed(name: 'Salary', type: TransactionType.income),
    CategorySeed(name: 'Freelance', type: TransactionType.income),
    CategorySeed(name: 'Other Income', type: TransactionType.income),
    CategorySeed(name: 'Groceries', type: TransactionType.expense),
    CategorySeed(name: 'Rent', type: TransactionType.expense),
    CategorySeed(name: 'Utilities', type: TransactionType.expense),
    CategorySeed(name: 'Transport', type: TransactionType.expense),
    CategorySeed(name: 'Dining', type: TransactionType.expense),
    CategorySeed(name: 'Health', type: TransactionType.expense),
    CategorySeed(name: 'Other Expenses', type: TransactionType.expense),
  ];
}
