import 'package:flutter/material.dart';
import 'package:test_ravidu/db/db_helper.dart';
import 'package:test_ravidu/widgets/job_card.dart';
import 'package:test_ravidu/utils/app_constants.dart';

class Userhomescreen extends StatefulWidget {
  const Userhomescreen({super.key});

  @override
  State<Userhomescreen> createState() => _UserhomescreenState();
}

class _UserhomescreenState extends State<Userhomescreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  Future<List<Map<String, dynamic>>>? _jobFuture;

  @override
  void initState() {
    super.initState();
    _jobFuture = DBHelper.getJobsByStatus('approved');
  }

  void _performSearch() {
    setState(() {
      _jobFuture = DBHelper.searchJobs(
        _searchController.text, 
        _locationController.text
      );
    });
  }

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
                    _locationController.text = city.startsWith("All of") ? district : city;
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _performSearch(); 
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Select Location"), backgroundColor: const Color(0xFF003366)),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: const Text("All Sri Lanka", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() => _locationController.text = "All Sri Lanka");
                  Navigator.pop(context);
                  _performSearch();
                },
              ),
              const Divider(),
              ...locations.keys.where((d) => d != "All Sri Lanka").map((district) {
                return ListTile(
                  title: Text(district),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _openCityPicker(district),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        // බටන් එකට ඉඩ ඕන නිසා උස 270 දක්වා වැඩි කළා
        preferredSize: const Size.fromHeight(270), 
        child: Container(
          color: const Color(0xFF003366),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Column( 
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tag_faces, color: Colors.white),
                  SizedBox(width: 5),
                  Text("Gem Hub ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Jobs ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 15),
              
              // 1. Search Field
              _buildSearchField(
                Icons.search, 
                "Search for jobs...", 
                _searchController,
                onSubmitted: (val) => _performSearch(),
              ),
              const SizedBox(height: 10),
              
              // 2. Location Field
              GestureDetector(
                onTap: _openLocationPicker,
                child: AbsorbPointer(
                  child: _buildSearchField(
                    Icons.location_on, 
                    "Search by location...", 
                    _locationController, 
                    hasSuffix: true
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 3. මෙන්න අලුතින් එක් කළ Search Button එක
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800], // Ikman style orange
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Search", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data!;
          if (jobs.isEmpty) return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No Jobs found for your search."),
          ));

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(job: jobs[index]),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(IconData icon, String hint, TextEditingController controller, {bool hasSuffix = false, Function(String)? onSubmitted}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: hasSuffix ? const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}