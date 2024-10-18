import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';

class GenerateWorkoutPlanScreen extends StatefulWidget {
  const GenerateWorkoutPlanScreen({super.key});

  @override
  _GenerateWorkoutPlanScreenState createState() =>
      _GenerateWorkoutPlanScreenState();
}

class _GenerateWorkoutPlanScreenState extends State<GenerateWorkoutPlanScreen> {
  String? _selectedGoal;
  String? _selectedExperience;
  bool _isLoading = false;
  Map<String, dynamic>? _workoutPlan;

  final List<String> _fitnessGoals = [
    'Lose weight',
    'Build muscle',
    'Improve cardiovascular health',
    'Increase flexibility',
    'Enhance overall fitness'
  ];

  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Plan Generator',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdownField(
                label: 'Select your fitness goal:',
                items: _fitnessGoals,
                value: _selectedGoal,
                onChanged: (value) {
                  setState(() => _selectedGoal = value);
                },
              ),
              const SizedBox(height: 24),
              _buildDropdownField(
                label: 'Select your experience level:',
                items: _experienceLevels,
                value: _selectedExperience,
                onChanged: (value) {
                  setState(() => _selectedExperience = value);
                },
              ),
              const SizedBox(height: 30),
              _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) =>
              value == null ? 'Please select an option' : null,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _isLoading ? null : _generateWorkoutPlan,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Generate Workout Plan',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
    );
  }

  Future<void> _generateWorkoutPlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _workoutPlan = null;
    });

    final gemini = Gemini.instance;
    try {
      final response = await gemini.text(
          "Generate a structured workout plan for someone with the goal of $_selectedGoal and experience level: $_selectedExperience. "
          "The plan should include: warm-up exercises, main workout routine, cool-down exercises, and nutrition tips. "
          "Format the response as a JSON object with these keys: warmUp, mainWorkout, coolDown, nutritionTips.");

      if (response?.output != null) {
        setState(() {
          _workoutPlan = _parseWorkoutPlan(response!.output!);
          _isLoading = false;
        });
        _showWorkoutPlanModal();
      } else {
        throw Exception('No output from Gemini');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorModal('Error generating workout plan: $e');
    }
  }

  void _showWorkoutPlanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          initialChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Your Personalized Workout Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildWorkoutPlanDisplay(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkoutPlanDisplay() {
    if (_workoutPlan != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _workoutPlan!.entries
            .map((entry) => _buildSection(entry.key, entry.value))
            .toList(),
      );
    } else {
      return const Text('No workout plan generated yet.');
    }
  }

  Widget _buildSection(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          if (content is List)
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item.toString()),
                ))
          else
            Text(content.toString()),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseWorkoutPlan(String text) {
    try {
      return jsonDecode(
          text.replaceAll('```json', '').replaceAll('```', '').trim());
    } catch (e) {
      return {'Error': 'Failed to parse workout plan'};
    }
  }

  void _showErrorModal(String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
