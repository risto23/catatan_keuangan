import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/database_helper.dart';

abstract class TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;

  TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });
}

class TransactionError extends TransactionState {}

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionLoading());

  List<TransactionModel> _allTransactions = [];

  Future<void> fetchTransactions() async {
    emit(TransactionLoading());
    try {
      final txs = await DatabaseHelper.instance.getTransactions();
      _allTransactions = txs;

      final totals = _calculateTotals(txs);

      emit(
        TransactionLoaded(
          transactions: txs,
          totalIncome: totals['income']!,
          totalExpense: totals['expense']!,
        ),
      );
    } catch (_) {
      emit(TransactionError());
    }
  }

  void filterByDateRange(DateTime start, DateTime end) {
    final filtered =
        _allTransactions
            .where(
              (tx) =>
                  tx.date.isAfter(start.subtract(const Duration(days: 1))) &&
                  tx.date.isBefore(end.add(const Duration(days: 1))),
            )
            .toList();

    final totals = _calculateTotals(filtered);

    emit(
      TransactionLoaded(
        transactions: filtered,
        totalIncome: totals['income']!,
        totalExpense: totals['expense']!,
      ),
    );
  }

  Map<String, double> _calculateTotals(List<TransactionModel> list) {
    double income = 0;
    double expense = 0;

    for (var tx in list) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    return {'income': income, 'expense': expense};
  }
}
