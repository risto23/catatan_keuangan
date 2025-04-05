import 'package:catatan_keuangan/screens/add_transaction_screen.dart';
import 'package:catatan_keuangan/screens/home_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final routes = {
    '/': (context) => const HomeScreen(),
    '/add': (context) => const AddTransactionScreen(),
  };
}
