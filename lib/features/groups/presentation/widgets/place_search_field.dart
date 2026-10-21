import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_state.dart';

class PlaceSearchField extends StatelessWidget {
  const PlaceSearchField({
    super.key,
    required this.controller,
    required this.onSelected,
    required this.onEdited,
    this.validator,
  });

  final TextEditingController controller;

  final ValueChanged<PlaceSuggestionEntity> onSelected;

  final VoidCallback onEdited;

  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.meetingEditLocationLabel,
          controller: controller,
          hintText: l10n.meetingEditLocationHint,
          validator: validator,
          onChanged: (value) {
            onEdited();
            context.read<PlaceSearchCubit>().search(value);
          },
        ),
        BlocBuilder<PlaceSearchCubit, PlaceSearchState>(
          builder: (context, state) {
            if (state.hasError) {
              return Padding(
                padding: EdgeInsets.only(top: spacing.s8),
                child: Text(
                  l10n.meetingEditLocationSearchError,
                  style: context.text.bodySmall.copyWith(
                    color: context.colors.feedbackError,
                  ),
                ),
              );
            }

            if (state.suggestions.isEmpty) {
              return state.isLoading
                  ? Padding(
                      padding: EdgeInsets.only(top: spacing.s8),
                      child: const LinearProgressIndicator(),
                    )
                  : const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(top: spacing.s8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.borderDefault),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (final place in state.suggestions)
                      _SuggestionTile(
                        place: place,
                        onTap: () {
                          controller.text = place.label;
                          context.read<PlaceSearchCubit>().clear();
                          FocusScope.of(context).unfocus();
                          onSelected(place);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.place, required this.onTap});

  final PlaceSuggestionEntity place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showAddress = !place.shortAddress.startsWith(place.name);

    return ListTile(
      key: ValueKey('place-suggestion-${place.googlePlaceId}'),
      leading: const Icon(Icons.place_outlined),
      title: Text(place.name, style: context.text.bodyDefaultEmphasis),
      subtitle: showAddress
          ? Text(
              place.shortAddress,
              style: context.text.bodySmall.copyWith(
                color: context.colors.textMuted,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
