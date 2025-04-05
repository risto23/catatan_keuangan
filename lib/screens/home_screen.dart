import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/cubit/transaction_cubit.dart';
import '../../../logic/cubit/theme_cubit.dart';
import '../../../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Keuangan"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogBackgroundColor:
                          isDark ? Colors.black : Colors.white,
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                context.read<TransactionCubit>().filterByDateRange(
                  picked.start,
                  picked.end,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => context.read<TransactionCubit>().fetchTransactions(),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final transactions = state.transactions;
            final balance = state.balance;

            return Column(
              children: [
                // Container Saldo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.indigo[100],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Saldo: Rp ${balance.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.indigo,
                    ),
                  ),
                ),

                // List Transaksi
                if (transactions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "Belum ada transaksi",
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: transactions.length,
                      itemBuilder:
                          (_, i) =>
                              TransactionTile(transaction: transactions[i]),
                    ),
                  ),
              ],
            );
          }

          return Center(
            child: Text(
              "Terjadi kesalahan.",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.red[300] : Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/add',
            ).then((_) => context.read<TransactionCubit>().fetchTransactions()),
        backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.indigo,
        child: Icon(
          Icons.add,
          color:
              isDark
                  ? Colors.white
                  : Colors.white, // Gunakan warna putih di semua mode
        ),
      ),

    );
  }
}
