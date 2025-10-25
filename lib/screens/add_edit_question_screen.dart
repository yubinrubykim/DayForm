import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final Question? question;

  const AddEditQuestionScreen({super.key, this.question});

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  late TextEditingController _textController;
  late QuestionType _selectedType;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question?.text ?? '');
    _selectedType = widget.question?.type ?? QuestionType.text;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        return '진행도 답변';
      case QuestionType.check:
        return '체크 답변';
    }
  }

  String _getTypeDescription(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return '자유롭게 텍스트로 답변할 수 있습니다';
      case QuestionType.progress:
        return '0-100% 사이의 진행도로 답변할 수 있습니다';
      case QuestionType.check:
        return '완료/미완료로 체크하여 답변할 수 있습니다';
    }
  }

  void _save() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문을 입력해주세요')),
      );
      return;
    }

    final question = Question(
      id: widget.question?.id ?? QuestionService.instance.generateQuestionId(),
      text: _textController.text.trim(),
      type: _selectedType,
    );

    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.question != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? '질문 수정' : '질문 추가',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              isEditing ? '수정' : '추가',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 질문 입력 섹션
            const Text(
              '질문',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '예: 오늘 어떤 일들을 했나요?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 32),

            // 답변 타입 선택 섹션
            const Text(
              '답변 타입',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '질문에 대한 답변 방식을 선택하세요',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // 타입 선택 카드들
            ...QuestionType.values.map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getTypeColor(type).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _getTypeColor(type)
                            : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _getTypeColor(type).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _getTypeIcon(type),
                            color: _getTypeColor(type),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTypeLabel(type),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? _getTypeColor(type)
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getTypeDescription(type),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? _getTypeColor(type)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected
                                ? _getTypeColor(type)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
