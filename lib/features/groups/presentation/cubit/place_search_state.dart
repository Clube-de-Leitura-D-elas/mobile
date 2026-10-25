import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';

class PlaceSearchState extends Equatable {
  const PlaceSearchState({
    this.suggestions = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  final List<PlaceSuggestionEntity> suggestions;
  final bool isLoading;
  final bool hasError;

  PlaceSearchState copyWith({
    List<PlaceSuggestionEntity>? suggestions,
    bool? isLoading,
    bool? hasError,
  }) {
    return PlaceSearchState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [suggestions, isLoading, hasError];
}
