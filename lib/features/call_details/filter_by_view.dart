import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import 'call_details_controller.dart';

class FilterByView extends GetView<CallDetailsController> {
  const FilterByView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.resetTempFilters();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Filter By',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.resetAllFilters,
            child: const Text(
              'Reset All',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 2-Column Split Body
            Expanded(
              child: Row(
                children: [
                  // Left Category Navigation Panel
                  Container(
                    width: 115,
                    color: const Color(0xFF191B24),
                    child: Obx(() {
                      final activeCategory = controller.selectedCategory.value;
                      return Column(
                        children: [
                          _buildCategoryTile(
                            title: 'Duration',
                            isSelected: activeCategory == 'Duration',
                            hasCheck: controller.tempDuration.value != 'All Time',
                            onTap: () => controller.selectedCategory.value = 'Duration',
                          ),
                          _buildCategoryTile(
                            title: 'Call Type',
                            isSelected: activeCategory == 'Call Type',
                            hasCheck: controller.tempCallType.value != 'All',
                            onTap: () => controller.selectedCategory.value = 'Call Type',
                          ),
                          _buildCategoryTile(
                            title: 'SIM Card',
                            isSelected: activeCategory == 'SIM Card',
                            hasCheck: controller.tempSim.value != 'All SIMs',
                            onTap: () => controller.selectedCategory.value = 'SIM Card',
                          ),
                          _buildCategoryTile(
                            title: 'Call Duration',
                            isSelected: activeCategory == 'Call Duration',
                            hasCheck: controller.tempDurationLength.value != 'All',
                            onTap: () => controller.selectedCategory.value = 'Call Duration',
                          ),
                          _buildCategoryTile(
                            title: 'Contact Type',
                            isSelected: activeCategory == 'Contact Type',
                            hasCheck: controller.tempContactType.value != 'All',
                            onTap: () => controller.selectedCategory.value = 'Contact Type',
                          ),
                        ],
                      );
                    }),
                  ),

                  // Right Options Content Panel
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: Obx(() {
                        final activeCategory = controller.selectedCategory.value;
                        if (activeCategory == 'Duration') {
                          return _buildDurationOptionsList(context);
                        } else if (activeCategory == 'Call Type') {
                          return _buildCallTypeOptionsList();
                        } else if (activeCategory == 'SIM Card') {
                          return _buildSimOptionsList();
                        } else if (activeCategory == 'Call Duration') {
                          return _buildDurationLengthOptionsList();
                        } else {
                          return _buildContactTypeOptionsList();
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Bottom Apply Button Container
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF191B24),
                border: Border(
                  top: BorderSide(color: Color(0xFF282B3C), width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  final count = controller.tempFilterCount;
                  return ElevatedButton(
                    onPressed: controller.applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Apply ($count)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required bool isSelected,
    required bool hasCheck,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        color: isSelected ? AppColors.background : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
            if (hasCheck)
              const Icon(
                Icons.check,
                color: Color(0xFF2563EB),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  String _formatCustomDates(DateTime start, DateTime end) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  Widget _buildDurationOptionsList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.durationOptions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF232532),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final option = controller.durationOptions[index];
        return Obx(() {
          final isSelected = controller.tempDuration.value == option;
          return InkWell(
            onTap: () async {
              controller.tempDuration.value = option;
              if (option == 'Custom') {
                final now = DateTime.now();
                final pickedRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: now,
                  initialDateRange: controller.tempCustomStartDate.value != null && controller.tempCustomEndDate.value != null
                      ? DateTimeRange(
                          start: controller.tempCustomStartDate.value!,
                          end: controller.tempCustomEndDate.value!,
                        )
                      : DateTimeRange(
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

                if (pickedRange != null) {
                  controller.setCustomRange(pickedRange.start, pickedRange.end);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                          ),
                        ),
                        if (option == 'Custom' &&
                            controller.tempCustomStartDate.value != null &&
                            controller.tempCustomEndDate.value != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatCustomDates(controller.tempCustomStartDate.value!, controller.tempCustomEndDate.value!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (option == 'Custom')
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCallTypeOptionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.callTypeOptions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF232532),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final option = controller.callTypeOptions[index];
        return Obx(() {
          final isSelected = controller.tempCallType.value == option;
          return InkWell(
            onTap: () => controller.tempCallType.value = option,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildSimOptionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.simOptions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF232532),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final option = controller.simOptions[index];
        return Obx(() {
          final isSelected = controller.tempSim.value == option;
          return InkWell(
            onTap: () => controller.tempSim.value = option,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDurationLengthOptionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.durationLengthOptions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF232532),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final option = controller.durationLengthOptions[index];
        return Obx(() {
          final isSelected = controller.tempDurationLength.value == option;
          return InkWell(
            onTap: () => controller.tempDurationLength.value = option,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildContactTypeOptionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.contactTypeOptions.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF232532),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final option = controller.contactTypeOptions[index];
        return Obx(() {
          final isSelected = controller.tempContactType.value == option;
          return InkWell(
            onTap: () => controller.tempContactType.value = option,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
