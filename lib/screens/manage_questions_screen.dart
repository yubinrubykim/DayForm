import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'add_edit_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;

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

  Future<void> _addQuestion() async {
    final result = await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditQuestionScreen(),
      ),
    );

    if (result != null) {
      await QuestionService.instance.addQuestion(result);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('질문이 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editQuestion(Question question) async {
    final result = await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuestionScreen(question: question),
      ),
    );

    if (result != null) {
      await QuestionService.instance.updateQuestion(question.id, result);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('질문이 수정되었습니다'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('질문 삭제'),
        content: Text('\'${question.text}\'\n질문을 삭제하시겠습니까?\n\n답변 기록은 유지됩니다.'),
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
      await QuestionService.instance.deleteQuestion(question.id);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('질문이 삭제되었습니다'),
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
          '질문 관리',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '질문이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '아래 버튼을 눌러 질문을 추가해보세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  onReorder: (oldIndex, newIndex) async {
                    await QuestionService.instance.reorderQuestions(oldIndex, newIndex);
                    await _loadQuestions();
                  },
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return _QuestionListItem(
                      key: ValueKey(question.id),
                      question: question,
                      onEdit: () => _editQuestion(question),
                      onDelete: () => _deleteQuestion(question),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('질문 추가'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _QuestionListItem extends StatelessWidget {
  final Question question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionListItem({
    super.key,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

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
        return '텍스트';
      case QuestionType.progress:
        return '진행도';
      case QuestionType.check:
        return '체크';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.drag_handle,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor(question.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(question.type),
                color: _getTypeColor(question.type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(question.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeLabel(question.type),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(question.type),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              color: Colors.blue,
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Colors.red,
              tooltip: '삭제',
            ),
          ],
        ),
      ),
    );
  }
}
