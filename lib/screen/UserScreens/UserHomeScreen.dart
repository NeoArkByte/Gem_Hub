import 'package:flutter/material.dart';
import 'package:test_ravidu/db/db_helper.dart';
import 'package:test_ravidu/screen/login.dart';
import 'package:test_ravidu/widgets/job_card.dart';
import 'package:test_ravidu/utils/app_constants.dart';
// AddJobScreen එක සහ LoginScreen එක import කරගන්න මතක තියාගන්න
import 'package:test_ravidu/screen/UserScreens/Jobs_Ads.dart';
// import 'package:test_ravidu/screens/login_screen.dart'; // ඔයාගේ ලොගින් පේජ් එක මෙතනට දාන්න

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
    // ඇප් එක ඕපන් කරද්දී Approved ජොබ්ස් ඔක්කොම පෙන්වන්න
    _jobFuture = DBHelper.getJobsByStatus('approved');
  }

  // සර්ච් එක ක්‍රියාත්මක කරන function එක
  void _performSearch() {
    setState(() {
      _jobFuture = DBHelper.searchJobs(
        _searchController.text,
        _locationController.text,
      );
    });
  }

  // නගර තෝරන Screen එක
  void _openCityPicker(String district) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Select City in $district"),
            backgroundColor: const Color(0xFF003366),
          ),
          body: ListView.builder(
            itemCount: locations[district]!.length,
            itemBuilder: (context, index) {
              String city = locations[district]![index];
              return ListTile(
                title: Text(city),
                onTap: () {
                  setState(() {
                    _locationController.text = city.startsWith("All of")
                        ? district
                        : city;
                  });
                  Navigator.pop(context); // නගරය වහනවා
                  Navigator.pop(context); // දිස්ත්‍රික්කය වහනවා
                  _performSearch(); // ලොකේෂන් එක තේරූ සැනින් සර්ච් වෙනවා
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // දිස්ත්‍රික්ක තෝරන Screen එක
  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Select Location"),
            backgroundColor: const Color(0xFF003366),
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.public, color: Colors.blue),
                title: const Text(
                  "All Sri Lanka",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() => _locationController.text = "All Sri Lanka");
                  Navigator.pop(context);
                  _performSearch();
                },
              ),
              const Divider(),
              ...locations.keys.where((d) => d != "All Sri Lanka").map((
                district,
              ) {
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
        preferredSize: const Size.fromHeight(270),
        child: Container(
          color: const Color(0xFF003366),
          // දකුණු පැත්තේ padding එක 10 දක්වා අඩු කළා Logout බටන් එකට ඉඩ දෙන්න
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 40,
            bottom: 10,
          ),
          child: Column(
            children: [
              // මෙතන තමයි Title එකයි Logout බටන් එකයි තියෙන්නේ
              Stack(
                alignment: Alignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tag_faces, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Gem Hub ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Jobs",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        // මෙතනින් Login Screen එකට යවනවා
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                        print("User Logged Out!");
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 1. Search Field
              _buildSearchField(
                Icons.search,
                "Search for jobs, companies...",
                _searchController,
                onSubmitted: (val) => _performSearch(),
              ),
              const SizedBox(height: 10),

              // 2. Location Picker Field
              GestureDetector(
                onTap: _openLocationPicker,
                child: AbsorbPointer(
                  child: _buildSearchField(
                    Icons.location_on,
                    "Search by location...",
                    _locationController,
                    hasSuffix: true,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 3. Search Button
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final jobs = snapshot.data!;
          if (jobs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No Jobs found for your search."),
              ),
            );
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(job: jobs[index]),
          );
        },
      ),
      // ජොබ් එකක් ඇඩ් කරන Floating Button එක
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
        },
        label: const Text(
          "Post a Job",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.orange[800],
      ),
    );
  }

  // TextField හදන Reusable Widget එක
  Widget _buildSearchField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool hasSuffix = false,
    Function(String)? onSubmitted,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: hasSuffix
              ? const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
