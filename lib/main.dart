import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sipcot/view/tn_district_maps.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/map_vm.dart';

void main() {
  Get.testMode = true;
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MapViewModel())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TnDistrictMaps(),
      ),
    ),
  );
}
