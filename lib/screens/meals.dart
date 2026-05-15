import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/providers/filters_provider.dart';
import 'package:meals/providers/meals_provider.dart';
import 'package:meals/screens/meal_details.dart';
import 'package:meals/widgets/meal_item.dart';

import '../models/meal.dart';

class MealScreen extends ConsumerWidget {
  const MealScreen({
    super.key,
    this.title,
    this.meals,
    this.categoryId,
    this.userMealsOnly = false,
  }) : assert(meals != null || categoryId != null);

  final String? title;
  final List<Meal>? meals;
  final String? categoryId;
  final bool userMealsOnly;

  void selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => MealDetailScreen(
        meal: meal,
      ),
    ));
  }

  List<Meal> _filterMeals(List<Meal> meals, Map<Filter, bool> activeFilters) {
    return meals.where((meal) {
      if (categoryId != null && !meal.categories.contains(categoryId)) {
        return false;
      }
      if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (activeFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (activeFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (activeFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildContent(BuildContext context, List<Meal> meals) {
    Widget content = Center(
      child: Text(
        'No meals available',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );

    if (meals.isNotEmpty) {
      content = ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) => MealItem(
          meal: meals[index],
          onSelectMeal: (context, meal) {
            selectMeal(context, meal);
          },
        ),
      );
    }

    if (title == null) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: content,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categoryId == null) {
      return _buildContent(context, meals!);
    }

    final activeFilters = ref.watch(filtersProvider);
    final mealsAsync =
        ref.watch(userMealsOnly ? mealsProvider : allMealsProvider);

    return mealsAsync.when(
      loading: () => Scaffold(
        appBar: title == null ? null : AppBar(title: Text(title!)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: title == null ? null : AppBar(title: Text(title!)),
        body: Center(
          child: Text(
            'Could not connect to server. Check your Node terminal!',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      data: (loadedMeals) {
        final filteredMeals = _filterMeals(loadedMeals, activeFilters);
        return _buildContent(context, filteredMeals);
      },
    );
  }
}
