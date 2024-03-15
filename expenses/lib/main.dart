// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, must_be_immutable, avoid_print, prefer_const_literals_to_create_immutables, deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/chart.dart';
import 'models/transaction.dart';
import 'components/transaction_form.dart';
import 'components/transaction_list.dart';

void main() {
  runApp(ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Quicksand',
          appBarTheme: AppBarTheme(
              titleTextStyle:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Novo Tênis de Corrida',
      amount: 310.76,
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
    Transaction(
      id: 't2',
      title: 'Conta de Luz',
      amount: 211.30,
      date: DateTime.now().subtract(Duration(days: 5)),
    ),
    Transaction(
      id: 't3',
      title: 'Boletos de Internet',
      amount: 211.30,
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
    Transaction(
      id: 't4',
      title: 'Conta de Água',
      amount: 211.30,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    Transaction(
      id: 't5',
      title: 'Bola de Vôlei',
      amount: 211.30,
      date: DateTime.now().subtract(Duration(days: 4)),
    ),
  ];

  bool _showChart = false;

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  double get _totalValue {
    return _transactions.fold(0.0, (sum, tr) {
      return sum + tr.amount;
    });
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  _addTransaction(String title, double amount, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      amount: amount,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool _isLandscape = mediaQuery.orientation == Orientation.landscape;
    final avaliableHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final appBar = AppBar(
      backgroundColor: Colors.purple,
      title: Text('Despesas Pessoais',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * MediaQuery.textScaleFactorOf(context),
          )),
      actions: <Widget>[
        if (_isLandscape)
          IconButton(
            icon: Icon(_showChart ? Icons.list : Icons.show_chart),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        IconButton(
          icon: Icon(Icons.add),
          color: Colors.white,
          onPressed: () => _openTransactionFormModal(context),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: avaliableHeight * (_isLandscape ? 0.2 : 0.10),
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'A soma das despesas é: R\$${_totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showChart || !_isLandscape)
                Container(
                  height: avaliableHeight * (_isLandscape ? 0.6 : 0.28),
                  child: Chart(_recentTransactions),
                ),
              if (!_showChart || !_isLandscape)
                Container(
                  height: avaliableHeight * (_isLandscape ? 0.95 : 0.57),
                  child: TransactionList(_transactions, _deleteTransaction),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: (! kIsWeb && Platform.isIOS) 
      ? const SizedBox() 
          : FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              onPressed: () => _openTransactionFormModal(context),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
