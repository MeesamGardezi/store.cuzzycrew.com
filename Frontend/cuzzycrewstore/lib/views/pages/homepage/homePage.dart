

import 'dart:async';
import 'dart:convert';

import 'package:cuzzycrewstore/controller/homeController.dart';
import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/views/pages/homepage/desktopHome.dart';
import 'package:cuzzycrewstore/views/pages/homepage/mobileHome.dart';
import 'package:cuzzycrewstore/views/pages/homepage/tabletHome.dart';
import 'package:cuzzycrewstore/views/widgets/CategoryBox.dart';
import 'package:cuzzycrewstore/views/widgets/ProductBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:carousel_text/carousel_text.dart';





class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return const HomeMobileLayout();
        } else if (constraints.maxWidth < 1024) {
          return const HomeTabletLayout();
        } else {
          return const HomeDesktopLayout();
        }
      },
    );
  }
}