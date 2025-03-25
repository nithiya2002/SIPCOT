import 'package:flutter/material.dart';
import 'package:sipcot/view/admin/widget/site_selection_dropdown.dart';

class SiteSelectionPage extends StatefulWidget {
  const SiteSelectionPage({super.key});

  @override
  State<SiteSelectionPage> createState() => _SiteSelectionPageState();
}

class _SiteSelectionPageState extends State<SiteSelectionPage> {
  String? _selectedSite;
  final List<String> _sites = [
    'Chennai - Bengaluru Expressway',
    'Pullalur Site-4',
    'Soorai Site-5',
    'Melpadi Site-6',
    'Kangeyam - Palladam - NH8/SH172',
    'Kangeyam Site-1',
    'Padiyur Site-2',
    'Panapalayam-1 Site-3',
    'Panapalayam-2 Site-4',
    'Panapalayam-3 Site-5',
    'Krishnagiri',
    'Nagamangalam',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SiteSelectionDropdown(
            sites: _sites,
            selectedSite: _selectedSite,
            onChanged: (site) {
              setState(() {
                _selectedSite = site;
              });
            },
          ),
          const SizedBox(height: 20),
          if (_selectedSite != null)
            Text(
              'Selected Site: $_selectedSite',
              style: const TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }
}
