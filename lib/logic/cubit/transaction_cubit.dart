import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/database_helper.dart';

abstract class TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double balance;

  TransactionLoaded({required this.transactions, required this.balance});
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
      emit(
        TransactionLoaded(transactions: txs, balance: _calculateBalance(txs)),
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

    emit(
      TransactionLoaded(
        transactions: filtered,
        balance: _calculateBalance(filtered),
      ),
    );
  }

  double _calculateBalance(List<TransactionModel> list) {
    double total = 0;
    for (var tx in list) {
      total += tx.type == 'income' ? tx.amount : -tx.amount;
    }
    return total;
  }
}
