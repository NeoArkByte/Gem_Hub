import 'package:flutter/material.dart';
import 'package:test_ravidu/db/db_helper.dart';
import 'package:test_ravidu/utils/app_constants.dart'; // Locations ටික ගන්න

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _title = TextEditingController();
  final _loc = TextEditingController();
  final _sal = TextEditingController();
  final _desc = TextEditingController();

  // දිස්ත්‍රික්ක තෝරන Screen එක
  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Select Location"), backgroundColor: const Color(0xFF003366)),
          body: ListView(
            children: locations.keys.where((d) => d != "All Sri Lanka").map((district) {
              return ListTile(
                title: Text(district),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => _openCityPicker(district),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // නගර තෝරන Screen එක
  void _openCityPicker(String district) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Select City in $district"), backgroundColor: const Color(0xFF003366)),
          body: ListView.builder(
            itemCount: locations[district]!.length,
            itemBuilder: (context, index) {
              String city = locations[district]![index];
              return ListTile(
                title: Text(city),
                onTap: () {
                  setState(() {
                    _loc.text = city.startsWith("All of") ? district : city;
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ජොබ් එක සේව් කරන Function එක
  void _submit() async {
    if (_title.text.isEmpty || _loc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Job Title and Location", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }
    
    await DBHelper.insertJob({
      'title': _title.text,
      'location': _loc.text,
      'salary': _sal.text,
      'description': _desc.text,
      'status': 'request', // මෙතන request කියලා දාන නිසා කෙලින්ම යන්නේ Pending ලිස්ට් එකට
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Job request submitted! Waiting for Admin approval.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // කලින් හිටපු Screen එකට ආපහු යනවා
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post New Job", style: TextStyle(color: Colors.white)), 
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Job Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _title, 
              decoration: const InputDecoration(labelText: "Job Title (e.g. Gem Cutter)", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),
            
            // Location Picker Field
            GestureDetector(
              onTap: _openLocationPicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: _loc, 
                  decoration: const InputDecoration(
                    labelText: "Location", 
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.location_on, color: Colors.blue)
                  )
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _sal, 
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Salary (e.g. 50000)", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _desc, 
              decoration: const InputDecoration(labelText: "Job Description", border: OutlineInputBorder()), 
              maxLines: 4
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Submit Job Request", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}