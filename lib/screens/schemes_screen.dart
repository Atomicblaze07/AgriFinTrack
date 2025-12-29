import 'package:flutter/material.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Govt Schemes for Farmers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SchemeCard(
            title: 'PM-KISAN (Income Support)',
            shortDesc:
                'Direct income support from Government of India for landholding farmers.',
            keyPoints: [
              'Eligible: Landholding farmer families with cultivable land in their name.',
              'Benefit: ₹6,000 per year in 3 instalments directly to bank account.',
              'Docs: Aadhaar, bank account, land records as per state.',
            ],
            howToApply:
                'Register through state agriculture department, Common Service Centre (CSC), or PM-KISAN portal.',
          ),
          SizedBox(height: 12),
          _SchemeCard(
            title: 'Kisan Credit Card (KCC)',
            shortDesc:
                'Credit card style loan facility for crop and allied activities.',
            keyPoints: [
              'Purpose: Timely and flexible credit for seeds, fertiliser, inputs and post-harvest needs.',
              'Limit: Typically up to ₹3 lakh depending on land, crop and bank policy.',
              'Benefits: Subsidised interest, simple documentation, revolving limit.',
            ],
            howToApply:
                'Visit nearby bank branch (public / cooperative / regional rural bank) and apply for KCC with land and identity documents.',
          ),
          SizedBox(height: 12),
          _SchemeCard(
            title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
            shortDesc:
                'Crop insurance scheme to protect farmers against yield loss.',
            keyPoints: [
              'Crops: Food crops, oilseeds, commercial and horticulture crops notified by state.',
              'Coverage: Risks from sowing to post-harvest including natural calamities and pests.',
              'Premium: Farmer pays a small share; remaining premium is subsidised by government.',
            ],
            howToApply:
                'Enroll through banks, insurance companies or online PMFBY portal during notified season for your crop and district.',
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final String title;
  final String shortDesc;
  final List<String> keyPoints;
  final String howToApply;

  const _SchemeCard({
    required this.title,
    required this.shortDesc,
    required this.keyPoints,
    required this.howToApply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(shortDesc),
            const SizedBox(height: 8),
            const Text(
              'Key points:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...keyPoints.map(
              (p) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(p)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How to apply:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(howToApply),
          ],
        ),
      ),
    );
  }
}
