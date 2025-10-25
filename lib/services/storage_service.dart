import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/answer.dart';

class StorageService {
  static const String _answersKey = 'answers';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveAnswer(Answer answer) async {
    if (_prefs == null) await init();

    final answers = await getAllAnswers();
    answers.add(answer);

    final answersJson = answers.map((a) => a.toJson()).toList();
    await _prefs!.setString(_answersKey, json.encode(answersJson));
  }

  Future<List<Answer>> getAllAnswers() async {
    if (_prefs == null) await init();

    final String? answersString = _prefs!.getString(_answersKey);
    if (answersString == null) return [];

    try {
      final List<dynamic> answersJson = json.decode(answersString) as List<dynamic>;
      return answersJson
          .map((json) => Answer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading answers: $e');
      return [];
    }
  }

  Future<List<Answer>> getAnswersByQuestionId(String questionId) async {
    final allAnswers = await getAllAnswers();
    return allAnswers.where((a) => a.questionId == questionId).toList();
  }

  Future<Answer?> getLatestAnswerForQuestion(String questionId) async {
    final answers = await getAnswersByQuestionId(questionId);
    if (answers.isEmpty) return null;

    answers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return answers.first;
  }

  Future<void> clearAllAnswers() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_answersKey);
  }
}
