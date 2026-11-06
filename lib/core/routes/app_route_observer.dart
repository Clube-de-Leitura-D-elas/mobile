import 'package:flutter/widgets.dart';

/// Avisa telas (via [RouteAware]) quando uma rota empilhada sobre elas é fechada.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
