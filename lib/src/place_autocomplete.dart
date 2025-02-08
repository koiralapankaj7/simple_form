import 'dart:async';

import 'package:collection_view/collection_view.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

///
class PlaceAutoComplete extends StatefulWidget {
  ///
  const PlaceAutoComplete({
    required PlacesService placesService,
    this.fieldViewBuilder = _defaultFieldViewBuilder,
    super.key,
  }) : _placesService = placesService;

  static Widget _defaultFieldViewBuilder(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return CupertinoSearchTextField(
      controller: textEditingController,
      focusNode: focusNode,
      onSubmitted: (_) => onFieldSubmitted(),
    );
    // return TextFormField(
    //   controller: textEditingController,
    //   focusNode: focusNode,
    //   decoration: decoration('Location'),
    //   onChanged: (value) {},
    // );
  }

  final PlacesService _placesService;

  /// {@macro flutter.widgets.RawAutocomplete.fieldViewBuilder}
  ///
  /// If not provided, will build a standard Material-style text field by
  /// default.
  final AutocompleteFieldViewBuilder fieldViewBuilder;

  @override
  State<PlaceAutoComplete> createState() => _PlaceAutoCompleteState();
}

class _PlaceAutoCompleteState extends State<PlaceAutoComplete> {
  late Debounceable<Iterable<PlacePrediction>?, String> _debouncedSearch;

  void _initSearch() {
    _debouncedSearch = AdvanceDebouncer.debounce(
      'placeAutocomplete',
      widget._placesService.getPlacePredictions,
    );
  }

  @override
  void initState() {
    super.initState();
    _initSearch();
  }

  @override
  void didUpdateWidget(covariant PlaceAutoComplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._placesService != oldWidget._placesService) {
      _initSearch();
    }
  }

  FutureOr<Iterable<PlacePrediction>> _optionsBuilder(
    TextEditingValue value,
  ) async {
    final res = await _debouncedSearch(value.text);
    return res ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<PlacePrediction>(
          optionsBuilder: _optionsBuilder,
          fieldViewBuilder: widget.fieldViewBuilder,
          optionsViewBuilder: (context, onSelected, options) {
            return _AutocompleteOptions(
              displayStringForOption: (option) => option.description,
              onSelected: onSelected,
              openDirection: OptionsViewOpenDirection.down,
              options: options,
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: constraints.maxWidth,
              ),
            );
          },
          onSelected: (option) {},
        );
      },
    );
  }
}

// The default Material-style Autocomplete options.
class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    required this.displayStringForOption,
    required this.onSelected,
    required this.openDirection,
    required this.options,
    required this.constraints,
    super.key,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;
  final OptionsViewOpenDirection openDirection;
  final Iterable<T> options;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final optionsAlignment = switch (openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    };
    return Align(
      alignment: optionsAlignment,
      child: Material(
        elevation: 4,
        child: ConstrainedBox(
          constraints: constraints,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                  builder: (BuildContext context) {
                    final highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    if (highlight) {
                      SchedulerBinding.instance.addPostFrameCallback(
                        (Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        },
                        debugLabel: 'AutocompleteOptions.ensureVisible',
                      );
                    }
                    return Container(
                      color: highlight ? Theme.of(context).focusColor : null,
                      padding: const EdgeInsets.all(16),
                      child: Text(displayStringForOption(option)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

///
class PlacePrediction extends Equatable {
  ///
  const PlacePrediction({
    required this.placeId,
    required this.description,
  });

  ///
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
    );
  }

  ///
  final String placeId;

  ///
  final String description;

  @override
  String toString() => description;

  @override
  List<Object?> get props => [placeId, description];
}

///
class PlaceDetails extends Equatable {
  ///
  const PlaceDetails({
    this.streetNumber,
    this.street,
    this.city,
    this.province,
    this.country,
    this.postalCode,
  });

  ///
  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      streetNumber: json['street_number'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
    );
  }

  ///
  final String? streetNumber;

  ///
  final String? street;

  ///
  final String? city;

  ///
  final String? province;

  ///
  final String? country;

  ///
  final String? postalCode;

  ///
  PlaceDetails copyWith({
    String? streetNumber,
    String? street,
    String? city,
    String? province,
    String? country,
    String? postalCode,
  }) {
    return PlaceDetails(
      streetNumber: streetNumber ?? this.streetNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      province: province ?? this.province,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  @override
  List<Object?> get props => [
        streetNumber,
        street,
        city,
        province,
        country,
        postalCode,
      ];
}

///
abstract class PlacesService {
  ///
  const PlacesService();

  ///
  Future<List<PlacePrediction>> getPlacePredictions(String input);

  ///
  Future<PlaceDetails?> getPlaceDetails(String placeId);
}

// ///
// class GooglePlacesService extends PlacesService {
//   ///
//   const GooglePlacesService({
//     required String apiKey,
//   }) : _apiKey = apiKey;

//   ///
//   static const baseUrl = 'maps.googleapis.com';

//   ///
//   static const autocompletePath = '/maps/api/place/autocomplete/json';

//   ///
//   static const placeDetailsPath = '/maps/api/place/details/json';

//   final String _apiKey;

//   ///
//   PlaceDetails? parseDetails(Map<String, dynamic>? json) {
//     final result = json?['result'];
//     if (result is! Map<String, dynamic>) return null;
//     final components = result['address_components'];
//     if (components is! List) return null;
//     var details = const PlaceDetails();
//     for (final component in components.whereType<Map<String, dynamic>>()) {
//       final types = component['types'];
//       final longName = component['long_name'];
//       if (types is! List || longName is! String) continue;
//       if (types.contains('street_number')) {
//         details = details.copyWith(streetNumber: longName);
//       } else if (types.contains('route')) {
//         details = details.copyWith(street: longName);
//       } else if (types.contains('locality')) {
//         details = details.copyWith(city: longName);
//       } else if (types.contains('administrative_area_level_1')) {
//         details = details.copyWith(province: longName);
//       } else if (types.contains('country')) {
//         details = details.copyWith(country: longName);
//       } else if (types.contains('postal_code')) {
//         details = details.copyWith(postalCode: longName);
//       }
//     }
//     return details;
//   }

//   @override
//   Future<List<PlacePrediction>> getPlacePredictions(String input) async {
//     if (input.isEmpty) return [];
//     final client = HttpClient();
//     try {
//       final uri = Uri.https(
//         baseUrl,
//         autocompletePath,
//         {
//           'input': input,
//           'types': 'address',
//           'fields': 'place_id,description',
//           'key': _apiKey,
//         },
//       );
//       final request = await client.getUrl(uri);
//       final response = await request.close();
//       if (response.statusCode != 200) return [];
//       final stringData = await response.transform(utf8.decoder).join();
//       final jsonData = jsonDecode(stringData) as Map<String, dynamic>?;
//       if (jsonData?['predictions'] case final List<dynamic> items) {
//         return items
//             .whereType<Map<String, dynamic>>()
//             .map(PlacePrediction.fromJson)
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       return [];
//     } finally {
//       client.close();
//     }
//   }

//   @override
//   Future<PlaceDetails?> getPlaceDetails(String placeId) async {
//     final client = HttpClient();
//     try {
//       final uri = Uri(
//         host: baseUrl,
//         path: autocompletePath,
//         queryParameters: {
//           'place_id': placeId,
//           'fields': 'address_component',
//           'key': _apiKey,
//         },
//       );
//       final request = await client.getUrl(uri);
//       final response = await request.close();
//       final stringData = await response.transform(utf8.decoder).join();
//       final jsonData = jsonDecode(stringData) as Map<String, dynamic>?;
//       if (response.statusCode != 200) return null;
//       return parseDetails(jsonData);
//     } catch (_) {
//       return null;
//     } finally {
//       client.close();
//     }
//   }
// }
