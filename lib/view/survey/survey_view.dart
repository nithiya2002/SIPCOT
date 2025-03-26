import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/view/survey/completed/survey_completed.dart';
import 'package:sipcot/view/survey/pending/survey_pending.dart';
import 'package:sipcot/viewModel/auth_view_model.dart';

class SurveyView extends StatefulWidget {
  const SurveyView({super.key});

  @override
  State<SurveyView> createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthViewModel>(context, listen: false).logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Completed'), Tab(text: 'Pending')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [SurveyCompleted(), SurveyPending()],
      ),
    );
  }
}
