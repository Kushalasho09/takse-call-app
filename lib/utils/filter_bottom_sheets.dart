import 'package:flutter/material.dart';

class FilterBottomSheets {
  static final List<String> durationOptions = [
    'Today',
    'Yesterday',
    'Week',
    'Month',
    'Custom',
    'All Time',
  ];

  static final List<String> callTypeOptions = [
    'All',
    'Incoming',
    'Outgoing',
    'Missed',
    'Rejected',
  ];

  static void showDurationBottomSheet(
    BuildContext context, {
    String selected = 'All Time',
    ValueChanged<String>? onSelected,
    void Function(DateTime start, DateTime end)? onCustomRangeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E202B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Title
              const Text(
                'Select Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Options List
              ...durationOptions.map((option) {
                final isSelected = selected == option;
                return Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        if (option == 'Custom') {
                          await pickCustomDateRange(context, onCustomRangeSelected);
                        } else {
                          if (onSelected != null) {
                            onSelected(option);
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Color(0xFF2563EB),
                                      size: 20,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFF2B2D3C),
                      height: 1,
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static Future<void> pickCustomDateRange(
    BuildContext context,
    void Function(DateTime start, DateTime end)? onCustomRangeSelected,
  ) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Color(0xFF1E202B),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF191A20)),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null && onCustomRangeSelected != null) {
      onCustomRangeSelected(pickedRange.start, pickedRange.end);
    }
  }

  static void showCallTypeBottomSheet(
    BuildContext context, {
    String selected = 'All',
    ValueChanged<String>? onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E202B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Title
              const Text(
                'Select Call Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Options List
              ...callTypeOptions.map((option) {
                final isSelected = selected == option;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (onSelected != null) {
                          onSelected(option);
                        }
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Color(0xFF2563EB),
                                      size: 20,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFF2B2D3C),
                      height: 1,
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static final List<Map<String, String>> excludeNoOptions = [
    {'title': 'Yes', 'subtitle': 'Exclude spam & ignored numbers from analytics'},
    {'title': 'No', 'subtitle': 'Include all phone numbers in analytics'},
  ];

  static void showExcludeNoBottomSheet(
    BuildContext context, {
    String selected = 'Yes',
    ValueChanged<String>? onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E202B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Exclude Numbers (Ex. No.)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose whether to filter out spam or excluded numbers from your call report calculations.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              ...excludeNoOptions.map((opt) {
                final option = opt['title']!;
                final subtitle = opt['subtitle']!;
                final isSelected = selected == option;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (onSelected != null) {
                          onSelected(option);
                        }
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons.circle_outlined,
                                      color: Color(0xFF64748B),
                                      size: 20,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ex. No.: $option',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFF2B2D3C),
                      height: 1,
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
