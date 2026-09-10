import 'package:equatable/equatable.dart';

class DropdownPreviewState extends Equatable {
  final String? selectedValue;

  const DropdownPreviewState({
    this.selectedValue,
  });

  DropdownPreviewState copyWith({
    String? selectedValue,
  }) {
    return DropdownPreviewState(
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }

  @override
  List<Object?> get props => [
        selectedValue,
      ];
}