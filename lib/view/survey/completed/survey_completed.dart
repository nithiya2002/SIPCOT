import 'package:flutter/material.dart';
import 'package:sipcot/view/survey/widget/list_menu_widget.dart';

import '../../../model/location_model.dart';

final Location startLocation = Location(12.974261350762218, 80.24944304427923);
final Location endLocation = Location(12.969278304369404, 80.24804364389884);

class SurveyCompleted extends StatefulWidget {
  const SurveyCompleted({super.key});

  @override
  State<SurveyCompleted> createState() => _SurveyCompletedState();
}

class _SurveyCompletedState extends State<SurveyCompleted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              ListMenuWidget(
                title: 'Survey Number: 158',
                subTitle: 'Completed Date: 25th April 2025',
                onTap: () {},
                numberString: "158",
                startLocation: startLocation,
                destinationLocation: endLocation,
              ),

              /*      ListMenuWidget(
                icon: Icons.login,
                title: 'Survey Number: 90',
                subTitle: 'Completed data: 24th April 2025',
                onTap: () {},
                numberString: "90",
              ),

              ListMenuWidget(
                icon: Icons.login,
                title: 'Survey Number: 110',
                subTitle: 'Completed data: 25th April 2025',
                onTap: () {},
                numberString: "110",
              ),
              ListMenuWidget(
                icon: Icons.login,
                title: 'Survey Number: 645',
                subTitle: 'Completed data: 25th April 2025',
                onTap: () {},
                numberString: "645",
              ),

              ListMenuWidget(
                icon: Icons.login,
                title: 'Survey Number: 115',
                subTitle: 'Completed data: 24th April 2025',
                onTap: () {},
                numberString: "115",
              ),

              ListMenuWidget(
                icon: Icons.login,
                title: 'Survey Number: 345',
                subTitle: 'Completed data: 25th April 2025',
                onTap: () {},
                numberString: "345",
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
