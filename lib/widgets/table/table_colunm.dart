import 'package:flutter/material.dart';

class TableColumn {
  final String header;
  final String key;
  final int flex;
  final bool sortable;
  final Widget Function(dynamic value, dynamic item)? customWidget;
  TableColumn({
    required this.header,
    required this.key,
    this.flex = 1,
    this.sortable = true,
    this.customWidget,
  });
}