import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../services/question_service.dart';
import '../services/storage_service.dart';
import '../widgets/text_answer_widget.dart';
import '../widgets/progress_answer_widget.dart';
import '../widgets/check_answer_widget.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    await QuestionService.instance.loadQuestions();
    setState(() {
      _questions = QuestionService.instance.getAllQuestions();
      _isLoading = false;
    });
  }

  Future<void> _clearAllAnswers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답변 초기화'),
        content: const Text('모든 답변을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.clearAllAnswers();
      if (mounted) {
        setState(() {
          // Force rebuild of all cards by changing key
          _refreshKey++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 답변이 삭제되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '오늘의 질문',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearAllAnswers,
            tooltip: '답변 초기화',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '질문이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadQuestions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _QuestionCard(
                        key: ValueKey('${question.id}_$_refreshKey'),
                        question: question,
                        onAnswerSaved: _loadQuestions,
                      );
                    },
                  ),
                ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final Question question;
  final VoidCallback onAnswerSaved;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.onAnswerSaved,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _isExpanded = false;
  bool _isSaving = false;
  Answer? _latestAnswer;
  final TextEditingController _textController = TextEditingController();
  double _progressValue = 50;
  bool _checkValue = false;

  @override
  void initState() {
    super.initState();
    _loadLatestAnswer();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestAnswer() async {
    final answer = await StorageService.instance
        .getLatestAnswerForQuestion(widget.question.id);
    if (mounted) {
      setState(() {
        _latestAnswer = answer;
        if (answer != null) {
          // Load previous answer into input fields
          if (widget.question.type == QuestionType.text) {
            _textController.text = answer.answer;
          } else if (widget.question.type == QuestionType.progress) {
            _progressValue = double.tryParse(answer.answer) ?? 50;
          } else if (widget.question.type == QuestionType.check) {
            _checkValue = answer.answer.toLowerCase() == 'true';
          }
        }
      });
    }
  }

  Future<void> _saveAnswer() async {
    String answerValue;

    if (widget.question.type == QuestionType.text) {
      if (_textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답변을 입력해주세요')),
        );
        return;
      }
      answerValue = _textController.text.trim();
    } else if (widget.question.type == QuestionType.progress) {
      answerValue = _progressValue.toInt().toString();
    } else {
      answerValue = _checkValue.toString();
    }

    setState(() => _isSaving = true);

    try {
      final answer = Answer(
        questionId: widget.question.id,
        answer: answerValue,
        timestamp: DateTime.now(),
      );

      await StorageService.instance.saveAnswer(answer);

      if (mounted) {
        await _loadLatestAnswer();

        setState(() {
          _isExpanded = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답변이 저장되었습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        widget.onAnswerSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswer = _latestAnswer != null;
    final backgroundColor = hasAnswer ? Colors.blue[50] : Colors.white;
    final borderColor = hasAnswer ? Colors.blue[300] : Colors.grey[200];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor!),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getTypeColor(widget.question.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(widget.question.type),
                        color: _getTypeColor(widget.question.type),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.question.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTypeLabel(widget.question.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasAnswer && !_isExpanded)
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                if (hasAnswer && !_isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getAnswerPreview(_latestAnswer!),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (widget.question.type == QuestionType.text)
                    TextAnswerWidget(controller: _textController)
                  else if (widget.question.type == QuestionType.progress)
                    ProgressAnswerWidget(
                      value: _progressValue,
                      onChanged: (value) {
                        setState(() => _progressValue = value);
                      },
                    )
                  else
                    CheckAnswerWidget(
                      value: _checkValue,
                      onChanged: (value) {
                        setState(() => _checkValue = value);
                      },
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '저장하기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAnswerPreview(Answer answer) {
    if (widget.question.type == QuestionType.progress) {
      return '${answer.answer}%';
    } else if (widget.question.type == QuestionType.check) {
      return answer.answer.toLowerCase() == 'true' ? '완료됨' : '미완료';
    }
    return answer.answer.length > 50
        ? '${answer.answer.substring(0, 50)}...'
        : answer.answer;
  }

  IconData _getTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return Icons.text_fields;
      case QuestionType.progress:
        return Icons.trending_up;
      case QuestionType.check:
        return Icons.check_box;
    }
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
        return '텍스트 답변';
      case QuestionType.progress:
        return '진행도 답변 (0-100%)';
      case QuestionType.check:
        return '체크 답변';
    }
  }
}
