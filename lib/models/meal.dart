enum Complexity {
  simple,
  challenging,
  hard,
}

enum Affordability {
  affordable,
  pricey,
  luxurious,
}

class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian,
  });

  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;

  // This is the essential "Translator" method
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      categories: List<String>.from(json['categories']),
      title: json['title'],
      imageUrl: json['imageUrl'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      duration: json['duration'],
      // Maps the String from MongoDB (e.g., "simple") to the Enum Complexity.simple
      complexity: Complexity.values.firstWhere(
        (e) => e.name == json['complexity'],
      ),
      affordability: Affordability.values.firstWhere(
        (e) => e.name == json['affordability'],
      ),
      isGlutenFree: json['isGlutenFree'] ?? false,
      isLactoseFree: json['isLactoseFree'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
    );
  }
}
