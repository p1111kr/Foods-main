import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class FavoriteMealsNotifier extends Notifier<List<Meal>> {
  @override
  List<Meal> build() {
    return [];
  }

  Future<void> fetchAndSetFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final url = Uri.parse('http://localhost:3000/user-favorites/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> listData = json.decode(response.body);

        // Convert the raw JSON list from MongoDB back into a List of Meal objects
        final List<Meal> loadedFavorites = listData.map((item) {
          return Meal.fromJson(item);
        }).toList();

        state = loadedFavorites;
      }
    } catch (error) {
      print('Error fetching favorites: $error');
    }
  }

  Future<bool> toggleMealFavoriteStatus(Meal meal) async {
    final mealIsFavorite = state.any((m) => m.id == meal.id);

    // 1. this Update UI state locally for speed
    if (mealIsFavorite) {
      state = state.where((m) => m.id != meal.id).toList();
    } else {
      state = [...state, meal];
    }

    // 2. this Sync with MongoDB in the background
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final url = Uri.parse('http://localhost:3000/update-favorites');
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': userId,
            'favorites': state.map((m) => m.id).toList(),
          }),
        );
      }
    } catch (error) {
      print("Failed to sync favorites: $error");
    }

    return !mealIsFavorite;
  }
}

final favoriteMealsProvider =
    NotifierProvider<FavoriteMealsNotifier, List<Meal>>(() {
  return FavoriteMealsNotifier();
});
