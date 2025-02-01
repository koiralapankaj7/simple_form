import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:collection_view/collection_view.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;

///
class CountryRepository extends Controller {
  ///
  CountryRepository._();

  ///
  static final CountryRepository _instance = CountryRepository._();

  ///
  static CountryRepository instance = _instance;

  List<Country> _countries = [];
  String _search = '';

  ///
  List<Country> get countries => _search.trim().isEmpty
      ? _countries
      : _countries
          .where(
            (e) =>
                e.name.toLowerCase().contains(_search) ||
                e.iso2.toLowerCase().contains(_search),
          )
          .toList();

  ///
  Future<void> loadCountries() async {
    try {
      final response = await rootBundle
          .loadString('packages/simple_form/json/countries.json');
      final countriesJson = json.decode(response) as List;
      _countries = countriesJson
          .map(
            (e) => Country.fromJson(e as Map<String, dynamic>),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } catch (e) {
      log('$e');
    }
  }

  ///
  Country? countryFrom(String? code) {
    if (code == null) return null;
    final term = code.toLowerCase();
    return _countries.firstWhereOrNull(
      (e) => e.name.toLowerCase() == term || e.iso2.toLowerCase() == term,
    );
  }

  ///
  void search(String term) {
    if (term == _search) return;
    _search = term.toLowerCase();
    notifyListeners();
  }
}

///
class Country extends Equatable {
  ///
  const Country({
    required this.name,
    required this.unicodeFlag,
    required this.iso2,
    this.dialCode,
    this.currency,
    this.flag,
  });

  ///
  factory Country.fromJson(Map<String, dynamic> map) {
    return Country(
      name: map['name'] as String,
      unicodeFlag: map['unicodeFlag'] as String,
      iso2: map['iso2'] as String,
      dialCode: map['dialCode'] as String?,
      currency: map['currency'] as String?,
      flag: map['flag'] as String?,
    );
  }

  ///
  final String name;

  ///
  final String unicodeFlag;

  ///
  final String iso2;

  ///
  final String? dialCode;

  ///
  final String? currency;

  ///
  final String? flag;

  ///
  Country copyWith({
    String? name,
    String? unicodeFlag,
    String? dialCode,
    String? iso2,
    String? currency,
    String? flag,
  }) {
    return Country(
      name: name ?? this.name,
      unicodeFlag: unicodeFlag ?? this.unicodeFlag,
      dialCode: dialCode ?? this.dialCode,
      iso2: iso2 ?? this.iso2,
      currency: currency ?? this.currency,
      flag: flag ?? this.flag,
    );
  }

  ///
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'unicodeFlag': unicodeFlag,
      'dialCode': dialCode,
      'iso2': iso2,
      'currency': currency,
      'flag': flag,
    };
  }

  @override
  List<Object> get props {
    return [
      name,
      iso2,
    ];
  }
}
