// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../main.dart';

class chartbar extends StatelessWidget {
  final String label;
  final double spendingamount;
  final double spendingpctoftotal;

  chartbar(this.label, this.spendingamount, this.spendingpctoftotal);
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('${spendingamount.toStringAsFixed(0)}'),
      SizedBox(height: 4),
      Container(
        height: 60,
        width: 10,
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              color: Color.fromRGBO(220, 220, 220, 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            heightFactor: spendingpctoftotal,
            child: Container(
                decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            )),
          ),
        ]),
      ),
      SizedBox(height: 4),
      Text(label),
    ]);
  }
}
