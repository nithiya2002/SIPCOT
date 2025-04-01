import 'package:flutter/material.dart';

import '../../../model/location_model.dart';
import '../../../utility/widget/text_icon/convert_text_icon.dart';
import 'map_button.dart';

class ListMenuWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onTap;
  final String numberString;
  final Location? startLocation;
  final Location? destinationLocation;

  const ListMenuWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
    required this.numberString,
    this.startLocation,
    this.destinationLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircularTextIcon(text: numberString),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          subTitle,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        trailing: MapButton(
          startLocation: startLocation,
          destinationLocation: destinationLocation,
        ),
        onTap: onTap,
      ),
    );
  }
}
