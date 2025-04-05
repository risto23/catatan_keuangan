import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/local/database_helper.dart';
import '../data/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubit/transaction_cubit.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        transaction.type == 'income'
            ? Icons.arrow_downward
            : Icons.arrow_upward,
        color: transaction.type == 'income' ? Colors.green : Colors.red,
      ),
      title: Text(transaction.title),
      subtitle: Text(DateFormat('dd MMM yyyy').format(transaction.date)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Rp ${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: transaction.type == 'income' ? Colors.green : Colors.red,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              Navigator.pushNamed(context, '/add', arguments: transaction);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Hapus Transaksi"),
                      content: const Text("Yakin ingin menghapus?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Hapus"),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await DatabaseHelper.instance.deleteTransaction(
                  transaction.id!,
                );
                context.read<TransactionCubit>().fetchTransactions();
              }
            },
          ),
        ],
      ),
    );
  }
}
