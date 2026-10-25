import 'package:equatable/equatable.dart';

class PlaceSuggestionEntity extends Equatable {
  const PlaceSuggestionEntity({
    required this.googlePlaceId,
    required this.name,
    required this.address,
  });

  final String googlePlaceId;
  final String name;
  final String address;

  /// Endereço sem o CEP do final (", 90010-273"), só para exibir.
  String get shortAddress =>
      address.replaceFirst(RegExp(r',\s*\d{5}-?\d{3}$'), '');

  /// Texto mostrado no campo de local depois de escolher a sugestão. Quando o
  /// resultado é um endereço, o nome repete o começo dele: mostra só o endereço.
  String get label =>
      shortAddress.startsWith(name) ? shortAddress : '$name - $shortAddress';

  @override
  List<Object?> get props => [googlePlaceId, name, address];
}
