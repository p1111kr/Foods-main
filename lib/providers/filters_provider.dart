import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum Filter { glutenFree, lactoseFree, vegetarian, vegan }

class FiltersNotifier extends Notifier<Map<Filter, bool>> {
  @override
  Map<Filter, bool> build() => {
        Filter.glutenFree: false,
        Filter.lactoseFree: false,
        Filter.vegetarian: false,
        Filter.vegan: false,
      };

  Future<void> fetchAndSetFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final response =
        await http.get(Uri.parse('http://localhost:3000/user-filters/$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      state = {
        Filter.glutenFree: data['glutenFree'] ?? false,
        Filter.lactoseFree: data['lactoseFree'] ?? false,
        Filter.vegan: data['vegan'] ?? false,
        Filter.vegetarian: data['vegetarian'] ?? false,
      };
    }
  }

  void setFilter(Filter filter, bool isActive) {
    state = {...state, filter: isActive};
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    await http.post(
      Uri.parse('http://localhost:3000/update-filters'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'filters': {
          'glutenFree': state[Filter.glutenFree],
          'lactoseFree': state[Filter.lactoseFree],
          'vegan': state[Filter.vegan],
          'vegetarian': state[Filter.vegetarian],
        }
      }),
    );
  }
}

final filtersProvider = NotifierProvider<FiltersNotifier, Map<Filter, bool>>(
    () => FiltersNotifier());
