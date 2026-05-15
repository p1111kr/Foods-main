import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/providers/filters_provider.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the current filter state
    final activeFilters = ref.watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Filters'),
      ),
      body: Column(
        children: [
          _buildFilterSwitch(
            context,
            ref,
            'Gluten-free',
            'Only include gluten-free meals.',
            activeFilters[Filter.glutenFree]!,
            Filter.glutenFree,
          ),
          _buildFilterSwitch(
            context,
            ref,
            'Lactose-free',
            'Only include lactose-free meals.',
            activeFilters[Filter.lactoseFree]!,
            Filter.lactoseFree,
          ),
          _buildFilterSwitch(
            context,
            ref,
            'Vegetarian',
            'Only include vegetarian meals.',
            activeFilters[Filter.vegetarian]!,
            Filter.vegetarian,
          ),
          _buildFilterSwitch(
            context,
            ref,
            'Vegan',
            'Only include vegan meals.',
            activeFilters[Filter.vegan]!,
            Filter.vegan,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSwitch(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    bool currentValue,
    Filter filter,
  ) {
    return SwitchListTile(
      value: currentValue,
      onChanged: (isChecked) {
        // 2. Updating the provider when the switch is toggled
        ref.read(filtersProvider.notifier).setFilter(filter, isChecked);
      },
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      activeThumbColor: Theme.of(context).colorScheme.tertiary,
      contentPadding: const EdgeInsets.only(left: 34, right: 22),
    );
  }
}
