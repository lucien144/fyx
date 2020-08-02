import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:fyx/model/Category.dart';

class ListHeader extends ListItemWithCategory {
  final Category header;
  final Function onTap;

  ListHeader(this.header, {this.onTap});

  @override
  int get category => header.idCat;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.onTap is Function ? this.onTap() : null,
      child: Container(
        decoration: BoxDecoration(color: PlatformTheme.of(context).primaryColor, border: Border(bottom: BorderSide(width: 1, color: Colors.white38))),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(
          header.jmeno,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
