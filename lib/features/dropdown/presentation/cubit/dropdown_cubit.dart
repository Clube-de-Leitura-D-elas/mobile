import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/dropdown/presentation/cubit/dropdown_state.dart';

class DropdownPreviewCubit extends Cubit<DropdownPreviewState> {
  DropdownPreviewCubit()
      : super(
          const DropdownPreviewState(
            selectedValue: 'Todos',
          ),
        );

  void selectValue(String value) {
    emit(
      state.copyWith(
        selectedValue: value,
      ),
    );
  }
}