import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Equivalentes no material_ui dos widgets que o marionette_flutter 0.6.0
/// reconhece de fábrica. A lista dele compara com os tipos de
/// `package:flutter/material.dart`, que não são os mesmos tipos do
/// material_ui, então sem isto os botões e campos somem de
/// `get_interactive_elements`.
const Set<Type> materialUiInteractiveTypes = {
  ButtonStyleButton,
  Checkbox,
  CheckboxListTile,
  DropdownButton,
  DropdownButtonFormField,
  ElevatedButton,
  FilledButton,
  FloatingActionButton,
  IconButton,
  InkWell,
  OutlinedButton,
  PopupMenuButton,
  Radio,
  RadioListTile,
  Slider,
  Switch,
  SwitchListTile,
  TextButton,
  TextField,
  TextFormField,
};

const appMarionetteConfiguration = MarionetteConfiguration(
  isInteractiveWidget: isMaterialUiInteractiveWidget,
  shouldStopTraversal: shouldStopTraversalAtMaterialUiWidget,
  extractText: extractMaterialUiText,
);

// Compara pelo nome sem os argumentos de tipo: `DropdownButton<String>` não
// é igual ao `DropdownButton` (`DropdownButton<dynamic>`) do conjunto.
final Set<String> _interactiveTypeNames = materialUiInteractiveTypes
    .map(_typeName)
    .toSet();

String _typeName(Type type) {
  final name = type.toString();
  final typeArgumentsStart = name.indexOf('<');
  return typeArgumentsStart == -1
      ? name
      : name.substring(0, typeArgumentsStart);
}

bool isMaterialUiInteractiveWidget(Type type) =>
    _interactiveTypeNames.contains(_typeName(type));

/// Como no Marionette, a travessia continua dentro de um [InkWell].
bool shouldStopTraversalAtMaterialUiWidget(Type type) =>
    _typeName(type) != _typeName(InkWell) &&
    isMaterialUiInteractiveWidget(type);

String? extractMaterialUiText(Element element) {
  final widget = element.widget;
  if (widget is TextField) {
    return widget.controller?.text;
  }
  if (widget is TextFormField) {
    return widget.controller?.text;
  }
  return null;
}
