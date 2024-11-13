import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/date_formatter.dart';
import '../utils/number_formatter.dart';

class TransactionTable extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Shares')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Date')),
      ],
      rows: transactions.map((transaction) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(transaction.stockSymbol)),
            DataCell(Text(transaction.quantity.toString())),
            DataCell(Text(NumberFormatter.formatCurrency(transaction.price))),
            DataCell(Text(DateFormatter.formatDate(transaction.date))),
          ],
        );
      }).toList(),
    );
  }
}