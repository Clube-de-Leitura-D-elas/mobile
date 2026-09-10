import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/dropdown/presentation/pages/dropdown_page.dart';

abstract class DropdownPreviewRoutes {
  static const String dropdownPreview = '/dropdown-preview';

  static List<RouteBase> get routes => [
        GoRoute(
          path: dropdownPreview,
          builder: (context, state) {
            return const DropdownPreviewPage();
          },
        ),
      ];
}