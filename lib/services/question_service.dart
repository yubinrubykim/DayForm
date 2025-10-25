import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuestionService {
  static const String _questionsKey = 'questions';
  static const String _migratedKey = 'questions_migrated';

  static QuestionService? _instance;
  List<Question> _questions = [];

  QuestionService._();

  static QuestionService get instance {
    _instance ??= QuestionService._();
    return _instance!;
  }

  Future<void> loadQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if already migrated
      final isMigrated = prefs.getBool(_migratedKey) ?? false;

      if (!isMigrated) {
        // First time: Load from JSON and migrate to SharedPreferences
        await _migrateFromJson(prefs);
      } else {
        // Load from SharedPreferences
        await _loadFromStorage(prefs);
      }
    } catch (e) {
      print('Error loading questions: $e');
      _questions = [];
    }
  }

  Future<void> _migrateFromJson(SharedPreferences prefs) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> questionsJson = jsonData['questions'] as List<dynamic>;

      _questions = questionsJson
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();

      // Save to SharedPreferences
      await _saveQuestionsToStorage(prefs);
      await prefs.setBool(_migratedKey, true);

      print('Questions migrated from JSON to SharedPreferences');
    } catch (e) {
      print('Error migrating questions: $e');
      _questions = [];
    }
  }

  Future<void> _loadFromStorage(SharedPreferences prefs) async {
    final String? questionsString = prefs.getString(_questionsKey);
    if (questionsString == null) {
      _questions = [];
      return;
    }

    try {
      final List<dynamic> questionsJson = json.decode(questionsString) as List<dynamic>;
      _questions = questionsJson
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading questions from storage: $e');
      _questions = [];
    }
  }

  Future<void> _saveQuestionsToStorage(SharedPreferences prefs) async {
    final questionsJson = _questions.map((q) => q.toJson()).toList();
    await prefs.setString(_questionsKey, json.encode(questionsJson));
  }

  Future<void> saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveQuestionsToStorage(prefs);
  }

  List<Question> getAllQuestions() {
    return List.unmodifiable(_questions);
  }

  Question? getQuestionById(String id) {
    try {
      return _questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addQuestion(Question question) async {
    _questions.add(question);
    await saveQuestions();
  }

  Future<void> updateQuestion(String id, Question updatedQuestion) async {
    final index = _questions.indexWhere((q) => q.id == id);
    if (index != -1) {
      _questions[index] = updatedQuestion;
      await saveQuestions();
    }
  }

  Future<void> deleteQuestion(String id) async {
    _questions.removeWhere((q) => q.id == id);
    await saveQuestions();
  }

  Future<void> reorderQuestions(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final question = _questions.removeAt(oldIndex);
    _questions.insert(newIndex, question);
    await saveQuestions();
  }

  String generateQuestionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'q$timestamp';
  }

  int get questionCount => _questions.length;
}
