import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionTitle('1. Information We Collect'),
            _buildSectionText(
              'We collect minimal information necessary to provide our services. This may include:',
            ),
            _buildBulletPoint('Basic account information (email, name)'),
            _buildBulletPoint('Usage data to improve our services'),
            _buildBulletPoint('Device information for compatibility'),

            const SizedBox(height: 24),
            _buildSectionTitle('2. How We Use Your Information'),
            _buildSectionText('Your information is used solely to:'),
            _buildBulletPoint('Provide and maintain our service'),
            _buildBulletPoint('Improve user experience'),
            _buildBulletPoint('Communicate important updates'),

            const SizedBox(height: 24),
            _buildSectionTitle('3. Data Security'),
            _buildSectionText(
              'We implement industry-standard security measures to protect your data. However, no method of electronic transmission or storage is 100% secure.',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('4. Third-Party Services'),
            _buildSectionText(
              'We may use third-party services that collect information used to identify you. Links to their privacy policies:',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('5. Changes to This Policy'),
            _buildSectionText(
              'We may update our Privacy Policy periodically. We will notify you of any changes by posting the new policy on this page.',
            ),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6546),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'I Understand',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF3B6546),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
