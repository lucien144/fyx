import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:fyx/model/Category.dart';

class ListHeader extends ListItemWithCategory {
  final Category header;

  ListHeader(this.header);

  @override
  int get category => header.idCat;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PlatformTheme.of(context).primaryColor,
      padding: EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Text(
        header.jmeno,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
