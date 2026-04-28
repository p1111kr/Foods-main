import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import '../models/meal.dart';

// 1. this Create a provider to read the saved User ID and also
//Change to autoDispose so it resets on logout
final mealsProvider = FutureProvider.autoDispose<List<Meal>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final userId = prefs.getString('userId') ?? '';

  // Moving the ID to the URL as a Query Parameter
  final url = Uri.parse('http://localhost:3000/meals?userId=$userId');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'user-id': userId,
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> listData = json.decode(response.body);
    return listData.map((item) => Meal.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load meals');
  }
});
