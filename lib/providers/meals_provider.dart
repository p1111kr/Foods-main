import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import '../config/api_config.dart';
import '../models/meal.dart';

Future<List<Meal>> _fetchMeals(Uri url, {String? userId}) async {
  print('Fetching meals from: $url');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      if (userId != null) 'user-id': userId,
    },
  );

  print('Meals response ${response.statusCode}: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> listData = json.decode(response.body);
    return listData.map((item) => Meal.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load meals');
  }
}

final allMealsProvider = FutureProvider.autoDispose<List<Meal>>((ref) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/meals');
  return _fetchMeals(url);
});

final mealsProvider = FutureProvider.autoDispose<List<Meal>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final userId = prefs.getString('userId') ?? '';
  if (userId.isEmpty) {
    print('No userId found while fetching user meals.');
    return [];
  }

  final url = Uri.parse('${ApiConfig.baseUrl}/meals?userId=$userId');
  return _fetchMeals(url, userId: userId);
});
