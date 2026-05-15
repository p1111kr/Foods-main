import 'package:flutter/material.dart';
import 'package:meals/models/category.dart';
import 'package:meals/screens/meals.dart';
import '../widgets/category_grid_item.dart';

const availableCats = [
  Category(id: 'c1', title: 'Italian', color: Colors.purple),
  Category(id: 'c2', title: 'Quick & easy', color: Colors.red),
  Category(id: 'c3', title: 'Ethiopian', color: Colors.lightGreen),
  Category(id: 'c4', title: 'German', color: Colors.amber),
  Category(id: 'c5', title: 'Light & Lovely', color: Colors.blue),
  Category(id: 'c6', title: 'Exotic', color: Colors.green),
  Category(id: 'c7', title: 'Breakfast', color: Colors.lightBlue),
  Category(id: 'c8', title: 'Asian', color: Colors.orange),
  Category(id: 'c9', title: 'French', color: Colors.pink),
  Category(id: 'c10', title: 'Summer', color: Colors.teal),
  Category(id: 'c11', title: 'My Meals', color: Colors.orange),
];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectedCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MealScreen(
          title: category.title,
          categoryId: category.id,
          userMealsOnly: category.id == 'c11',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          for (final category in availableCats)
            CategoryGridItem(
              category: category,
              onSelectCategory: () => _selectedCategory(context, category),
            )
        ],
      ),
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: child,
      ),
    );
  }
}
