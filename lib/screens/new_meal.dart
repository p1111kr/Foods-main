import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:meals/config/api_config.dart';
import 'package:meals/providers/meals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMealScreen extends ConsumerStatefulWidget {
  const NewMealScreen({super.key});

  @override
  ConsumerState<NewMealScreen> createState() => _NewMealScreenState();
}

class _NewMealScreenState extends ConsumerState<NewMealScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  Uint8List? _webImage;
  bool _isUploading = false;

  String get _localUrl => '${ApiConfig.baseUrl}/meals';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImage = bytes;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _webImage = null;
    });
  }

  Future<void> _saveMeal() async {
    if (_titleController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _stepsController.text.isEmpty ||
        _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // FETCH THE ACTUAL USER ID FROM SHARED PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final userId = prefs.getString('userId')?.trim();
      print('Saving meal for userId: $userId');

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in before saving.')),
          );
        }
        return;
      }

      final String base64Image = base64Encode(_webImage!);
      final ingredientsList = _ingredientsController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      final stepsList = _stepsController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList();

      final response = await http.post(
        Uri.parse(_localUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': 'm${DateTime.now().millisecondsSinceEpoch}',
          'userId': userId,
          'title': _titleController.text,
          'imageUrl': 'data:image/jpeg;base64,$base64Image',
          'categories': ['c11'],
          'ingredients': ingredientsList,
          'steps': stepsList,
          'duration': 15,
          'complexity': 'simple',
          'affordability': 'affordable',
          'isGlutenFree': true,
          'isLactoseFree': true,
          'isVegan': true,
          'isVegetarian': true,
        }),
      );

      print('--- MONGODB DEBUG ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          ref.invalidate(allMealsProvider);
          ref.invalidate(mealsProvider);
          await ref.read(allMealsProvider.future);
          await ref.read(mealsProvider.future);
        } catch (_) {
          ref.invalidate(allMealsProvider);
          ref.invalidate(mealsProvider);
        }

        if (!mounted) return;

        _titleController.clear();
        _ingredientsController.clear();
        _stepsController.clear();
        setState(() {
          _webImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe Added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection Error.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Your Recipe',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Meal Title',
                  labelStyle: TextStyle(color: Colors.orange)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Ingredients (one per line)',
                  labelStyle: TextStyle(color: Colors.orange),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _stepsController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Cooking Steps (one per line)',
                  labelStyle: TextStyle(color: Colors.orange),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: _webImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(_webImage!, fit: BoxFit.cover))
                      : const Center(
                          child: Text('No image selected',
                              style: TextStyle(color: Colors.white70))),
                ),
                if (_webImage != null)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      onPressed: _removeImage,
                      icon:
                          const Icon(Icons.cancel, color: Colors.red, size: 30),
                    ),
                  ),
              ],
            ),
            TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.orange),
                label: const Text('Add Image',
                    style: TextStyle(color: Colors.orange))),
            const SizedBox(height: 30),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 15)),
                      child: const Text('Save Recipe',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
