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

  @override 
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

  void _filter(String e_keyword) {
    List<Map<String, dynamic>> results = [];
    if (e_keyword.isEmpty) {
      results = _allGems;
    } else {
      results = _allGems
          .where(
            (gem) => gem['name'].toLowerCase().contains(e_keyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _foundGems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gem Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => _filter(value),
              decoration: const InputDecoration(
                labelText: 'Search Gems.....',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _foundGems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundGems.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundGems[index]['id']),
                        color: Colors.blueGrey[50],
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.diamond, color: Colors.white),
                          ),
                          title: Text(
                            _foundGems[index]['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Category: ${_foundGems[index]['category']} | Weight: ${_foundGems[index]['weight']} cts",
                          ),
                          trailing: Text(
                            "Rs. ${_foundGems[index]['price']}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ) 
                  : const Center(
                      child: Text(
                        'No gems found!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}