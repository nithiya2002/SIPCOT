import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sipcot/utility/custom_logger.dart';
import '../survey_form/survey_form.dart';
import '../widget/list_menu_widget.dart';
import '../../../model/location_model.dart';

final Location startLocation = Location(12.974261350762218, 80.24944304427923);
final Location endLocation = Location(12.969278304369404, 80.24804364389884);

class SurveyPending extends StatefulWidget {
  const SurveyPending({super.key});

  @override
  State<SurveyPending> createState() => _SurveyPendingState();
}

class _SurveyPendingState extends State<SurveyPending> {
  final log = createLogger(SurveyPending);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListMenuWidget(
                    title: 'Survey Number: 158',
                    subTitle: 'Deadline Date: 25th April 2025',
                    onTap: () {
                      log.i('form field page');
                      Get.to(SurveyForm());
                    },
                    numberString: "158",
                    startLocation: startLocation,
                    destinationLocation: endLocation,
                  ),

                  // ListMenuWidget(
                  //   icon: Icons.login,
                  //   title: 'Survey Number: 90',
                  //   subTitle: 'Deadline Date: 27th April 2025',
                  //   onTap: () {},
                  //   numberString: "90",
                  // ),

                  // ListMenuWidget(
                  //   icon: Icons.login,
                  //   title: 'Survey Number: 110',
                  //   subTitle: 'Deadline Date: 27th April 2025',
                  //   onTap: () {},
                  //   numberString: "110",
                  // ),
                  // ListMenuWidget(
                  //   icon: Icons.login,
                  //   title: 'Survey Number: 645',
                  //   subTitle: 'Deadline Date: 25th April 2025',
                  //   onTap: () {},
                  //   numberString: "645",
                  // ),

                  // ListMenuWidget(
                  //   icon: Icons.login,
                  //   title: 'Survey Number: 115',
                  //   subTitle: 'Deadline Date: 24th April 2025',
                  //   onTap: () {},
                  //   numberString: "115",
                  // ),

                  // ListMenuWidget(
                  //   icon: Icons.login,
                  //   title: 'Survey Number: 345',
                  //   subTitle: 'Deadline Date: 25th April 2025',
                  //   onTap: () {},
                  //   numberString: "345",
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
