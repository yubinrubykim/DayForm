import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../services/storage_service.dart';
import '../services/question_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Answer> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    setState(() => _isLoading = true);
    final answers = await StorageService.instance.getAllAnswers();
    // Sort by timestamp descending (newest first)
    answers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _answers = answers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '답변 히스토리',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _answers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '아직 답변이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnswers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _answers.length,
                    itemBuilder: (context, index) {
                      final answer = _answers[index];
                      final question = QuestionService.instance
                          .getQuestionById(answer.questionId);
                      return _AnswerHistoryCard(
                        answer: answer,
                        question: question,
                      );
                    },
                  ),
                ),
    );
  }
}

class _AnswerHistoryCard extends StatelessWidget {
  final Answer answer;
  final Question? question;

  const _AnswerHistoryCard({
    required this.answer,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');
    final questionType = question?.type ?? QuestionType.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(questionType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTypeLabel(questionType),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(questionType),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(answer.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question?.text ?? '알 수 없는 질문',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (questionType == QuestionType.text)
              _buildTextAnswer()
            else if (questionType == QuestionType.progress)
              _buildProgressAnswer()
            else
              _buildCheckAnswer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAnswer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        answer.answer,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildProgressAnswer() {
    final progress = int.tryParse(answer.answer) ?? 0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$progress%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckAnswer() {
    final isChecked = answer.answer.toLowerCase() == 'true';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.cancel,
            color: isChecked ? Colors.green : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isChecked ? '완료됨' : '미완료',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isChecked ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return Colors.blue;
      case QuestionType.progress:
        return Colors.green;
      case QuestionType.check:
        return Colors.orange;
    }
  }

  String _getTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return '텍스트';
      case QuestionType.progress:
        return '진행도';
      case QuestionType.check:
        return '체크';
    }
  }
}
