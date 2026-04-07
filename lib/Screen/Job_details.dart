import 'package:flutter/material.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job; // 👇 Meka thamai aluthin add kale

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  final Color primaryGreen = const Color(0xFF10C971);
  final Color textColor = const Color(0xFF111827);
  final Color greyText = const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.ios_share,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildTagsRow(),
              const SizedBox(height: 32),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildSalaryCard(),
              const SizedBox(height: 32),
              _buildExpertiseSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionArea(),
    );
  }

  Widget _buildHeaderSection() {
    // DB eke companyInfo eke "Name • Location" widihata thiyenne, eka split karagamu
    List<String> companyParts = job['companyInfo'].toString().split(' • ');
    String companyName = companyParts[0];
    String location = companyParts.length > 1 ? companyParts[1] : 'Remote';

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                color: Color(job['logoColor']), // DB eken ena pata
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white38,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            job['title'], // DB eken ena Job Title eka
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                companyName, // Split karapu company name eka
                style: TextStyle(
                  fontSize: 16,
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.verified, color: primaryGreen, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$location • Active Listing', // Split karapu location eka
            style: TextStyle(fontSize: 14, color: greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow() {
    // DB eke comma-separated string eka list ekak karanawa
    List<String> tagsList = (job['tags'] as String).split(',');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: tagsList.map((tag) {
        return _buildTag(
          Icons.check_circle_outline,
          tag.trim(),
          Colors.grey[100]!,
          const Color(0xFF4B5563),
        );
      }).toList(),
    );
  }

  Widget _buildTag(
    IconData icon,
    String text,
    Color bgColor,
    Color tagTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tagTextColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: tagTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We are seeking an experienced professional for the ${job['title']} position. You will be responsible for handling premium gemstones, maintaining high-quality standards, and working closely with our international teams. (Description is currently standard for all posts).',
          style: TextStyle(fontSize: 15, color: greyText, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSalaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPECTED SALARY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: greyText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    job['salary'], // DB eken ena Salary eka
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_outlined, color: primaryGreen, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Expertise',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildExpertiseItem(
          'Industry Experience',
          'Prior experience in the gem and jewelry sector.',
        ),
        _buildExpertiseItem(
          'Quality Control',
          'Strict adherence to GIA and AGS grading standards.',
        ),
        _buildExpertiseItem(
          'Reliability',
          'Proven track record of handling high-value materials.',
        ),
      ],
    );
  }

  Widget _buildExpertiseItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: greyText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.black),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Apply Now button logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
