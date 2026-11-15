import 'package:material_ui/material_ui.dart';

/// Mantém a aba montada fora da tela: sem isso o `TabBarView` descarta o
/// texto digitado na busca, enquanto o cubit continua com a consulta antiga.
class KeepAliveTab extends StatefulWidget {
  final Widget child;

  const KeepAliveTab({super.key, required this.child});

  @override
  State<KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
