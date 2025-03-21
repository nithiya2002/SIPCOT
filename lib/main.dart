import 'package:flutter/material.dart';
import 'package:sipcot/view/tn_district_maps.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/map_vm.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => MapViewModel())],
      child: MaterialApp(home: TnDistrictMaps()),
    ),
  );
}
