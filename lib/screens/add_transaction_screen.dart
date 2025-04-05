import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/database_helper.dart';
import '../../../data/models/transaction_model.dart';
import '../../../logic/cubit/transaction_cubit.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now();
  String _type = 'income';
  int? _id;

  @override
  void didChangeDependencies() {
    final tx = ModalRoute.of(context)?.settings.arguments as TransactionModel?;
    if (tx != null) {
      _id = tx.id;
      _title.text = tx.title;
      _amount.text = tx.amount.toString();
      _date = tx.date;
      _type = tx.type;
    }
    super.didChangeDependencies();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final tx = TransactionModel(
        id: _id,
        title: _title.text,
        amount: double.parse(_amount.text),
        date: _date,
        type: _type,
      );

      if (_id == null) {
        await DatabaseHelper.instance.insertTransaction(tx);
      } else {
        await DatabaseHelper.instance.updateTransaction(tx);
      }

      context.read<TransactionCubit>().fetchTransactions();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_id == null ? "Tambah Transaksi" : "Edit Transaksi"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [Colors.black, Colors.grey[900]!]
                    : [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // === Input Judul ===
              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: "Judul",
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // === Input Jumlah ===
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Jumlah",
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // === Input Tanggal ===
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tanggal: ${DateFormat('dd MMM yyyy').format(_date)}",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
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
                      if (picked != null) setState(() => _date = picked);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pilih"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // === Input Tipe (Dropdown) ===
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: "Tipe",
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text(
                      "Pemasukan",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text(
                      "Pengeluaran",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),

              const SizedBox(height: 30),

              // === Tombol Simpan ===
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(
                  _id == null ? "Simpan Transaksi" : "Simpan Perubahan",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? Colors.deepPurpleAccent : Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
