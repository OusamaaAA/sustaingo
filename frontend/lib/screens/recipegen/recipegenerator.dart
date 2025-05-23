import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeGeneratorScreen extends StatefulWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  State<RecipeGeneratorScreen> createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ingredientsController = TextEditingController();
  List<dynamic> _recipes = [];
  bool _isLoading = false;
  int _displayCount = 10;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    final ingredients = _ingredientsController.text.trim();
    if (ingredients.isEmpty) {
      setState(() {
        _recipes = [];
        _displayCount = 10;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _recipes = [];
      _displayCount = 10;
    });

    try {
      final uri = Uri.parse(
          'https://new-recipe-generator.onrender.com/semantic_recommend?ingredients=$ingredients');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
        setState(() {
          _recipes = data;
        });
        _animationController.forward(from: 0);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching recipes')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> launchUrlInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, int index) {
    final name = recipe['name'];
    final ingredients = List<String>.from(recipe['ingredients']);
    final score = recipe['score'];
    final inputIngredients = _ingredientsController.text.toLowerCase().split(',').map((e) => e.trim()).toSet();


    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index / (_displayCount > 0 ? _displayCount : 1),
          1.0,
          curve: Curves.elasticOut,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final url = Uri.encodeFull('https://www.google.com/search?q=$name recipe');
          launchUrlInBrowser(url);
        },
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '⭐ ${_getMatchTitle(score)}',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(height: 10),
                const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...ingredients.map((ing) {
                  final isMatched = inputIngredients.contains(ing.toLowerCase());
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.black)),
                        Expanded(
                          child: Text(
                            ing,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: isMatched ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMatchTitle(double score) {
    if (score >= 0.65) return "Perfect culinary match!";
    if (score >= 0.55) return "A tasty match made just for you!";
    return "Worth a try with your ingredients!";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recipe Inspiration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF388E3C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Let's inspire a delicious meal with your available ingredients!",
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _ingredientsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter ingredients separated by commas',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _generateRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2d6a4f),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline),
                SizedBox(width: 10),
                Text(
                  'Get Recipe Idea',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          if (_recipes.isNotEmpty)
            ..._recipes.take(_displayCount).toList().asMap().entries.map((entry) => _buildRecipeCard(entry.value, entry.key)).toList(),
          if (_recipes.length > _displayCount)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _displayCount += 5), // Show 5 more recipes
                child: const Text("Show More"),
              ),
            ),
        ],
      ),
    );
  }
}
