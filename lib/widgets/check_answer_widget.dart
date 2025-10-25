import 'package:flutter/material.dart';

class CheckAnswerWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CheckAnswerWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '완료 여부를 선택해주세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: CheckboxListTile(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            title: Text(
              value ? '완료됨' : '미완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: value ? Colors.green[700] : Colors.grey[700],
              ),
            ),
            subtitle: Text(
              value ? '목표를 달성했습니다!' : '체크하여 완료 표시',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            secondary: Icon(
              value ? Icons.check_circle : Icons.radio_button_unchecked,
              color: value ? Colors.green : Colors.grey[400],
              size: 32,
            ),
            activeColor: Colors.green,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
