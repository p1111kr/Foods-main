import 'package:flutter/material.dart';

// our origional map
Map<String, Color> colorMap = {
  'purple': Colors.purple,
  'red': Colors.red,
  'orange': Colors.orange,
  'amber': Colors.amber,
  'blue': Colors.blue,
  'green': Colors.green,
  'lightBlue': Colors.lightBlue,
  'lightGreen': Colors.lightGreen,
  'pink': Colors.pink,
  'teal': Colors.teal,
};

class Category {
  const Category({
    required this.id,
    required this.title,
    this.color = Colors.orange,
  });

  final String id;
  final String title;
  final Color color;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      // This looks up the string e.g. red in our map
      // but If it can't find it, it defaults to orange
      color: colorMap[json['color']] ?? Colors.orange,
    );
  }
}
