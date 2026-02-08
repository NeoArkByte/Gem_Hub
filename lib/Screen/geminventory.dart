import 'package:flutter/material.dart';
import 'package:test_ravidu/dataBase/database.dart';

class inventory extends StatefulWidget {
  const inventory({super.key});

  @override
  State<inventory> createState() => _inventoryState();
}

class _inventoryState extends State<inventory> {
  List<Map<String, dynamic>> _allGems = [];

  List<Map<String, dynamic>> _foundGems = [];

  void initState() {
    super.initState();
    _refreshGems();
  }

  void _refreshGems() async {
    final data = await DBhelper.queryAllGems();
    setState(() {
      _allGems = data;
      _foundGems = data;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
