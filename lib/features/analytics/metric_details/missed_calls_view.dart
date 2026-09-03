import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/call_log_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/filter_bottom_sheets.dart';
import '../../routes/app_pages.dart';

class MissedCallsView extends StatelessWidget {
  const MissedCallsView({super.key});

  @override
  Widget build(BuildContext context) {
    final missedItems = [
      {
        'name': 'Jhuni Fua',
        'number': '+917070121461',
        'time': 'Today | 09:54 PM',
      },
      {
        'name': 'Bhabhi',
        'number': '+919905608748',
        'time': 'Today | 09:16 PM',
      },
      {
        'name': 'Unknown',
        'number': '+916203666624',
        'time': 'Today | 03:49 PM',
      },
      {
        'name': 'Unknown',
        'number': '+916203666624',
        'time': 'Today | 03:48 PM',
      },
      {
        'name': 'Bhaiya Jio',
        'number': '+917979009290',
        'time': 'Today | 01:46 PM',
      },
      {
        'name': 'Bhaiya Jio',
        'number': '+917979009290',
        'time': 'Today | 01:34 PM',
      },
    ];

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
          'Missed Calls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Filters Pill Row (Interactive)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Filter Pill (2) -> Opens FilterByView
                    _buildFilterPill(
                      onTap: () => Get.toNamed(AppRoutes.filterBy),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.filter_alt_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort By Dropdown Pill -> Opens Call Type / Sort Bottom Sheet
                    _buildFilterPill(
                      onTap: () => FilterBottomSheets.showCallTypeBottomSheet(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sort By:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Today Dropdown Pill -> Opens Duration Bottom Sheet
                    _buildFilterPill(
                      onTap: () => FilterBottomSheets.showDurationBottomSheet(context, selected: 'Today'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Ex. No.:Yes Dropdown Pill
                    _buildFilterPill(
                      onTap: () => FilterBottomSheets.showCallTypeBottomSheet(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ex. No.:Yes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar Range Banner
              Row(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '29-Jul-2026 12:00 AM - 29-Jul-2026 11:59 PM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Missed Calls List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: missedItems.length,
                itemBuilder: (context, index) {
                  final item = missedItems[index];
                  return _buildMissedCard(
                    name: item['name']!,
                    number: item['number']!,
                    time: item['time']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMissedCard({
    required String name,
    required String number,
    required String time,
  }) {
    final logItem = CallLogItem(
      id: UniqueKey().toString(),
      name: name,
      number: number,
      type: CallType.missed,
      timestamp: DateTime.now(),
      durationInSeconds: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF282B3C), width: 1),
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Name/Number + Time + Missed Status (Tapping navigates to CallDetailsView)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.callDetails, arguments: logItem),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF64748B),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Time Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      time.split('|')[0].trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time.split('|')[1].trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Missed Icon + Missed Label & Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.call_missed_rounded,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Missed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // SIM Badge [1]
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0h 0m 0s',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Note Container (Tapping navigates to AddNoteView)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.addNote, arguments: logItem),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14151E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222432), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'No notes attached yet',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
