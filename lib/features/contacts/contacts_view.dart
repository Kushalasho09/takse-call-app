import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../utils/animated_loader.dart';
import '../../utils/app_theme.dart';
import '../../utils/permission_required_widget.dart';
import '../routes/app_pages.dart';
import 'contacts_controller.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ContactsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'contacts_fab',
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(
          Icons.dialpad_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: AppAnimatedPulseLoader(loadingText: 'Checking permissions...'),
            );
          }

          if (!controller.hasPermission.value) {
            return PermissionRequiredWidget(
              title: 'Contacts Permission Required',
              description:
                  'Task Call needs to access your contacts to display names and allow quick calls, WhatsApp messaging, and call analytics. We store data locally on your device.',
              icon: Icons.contacts_rounded,
              buttonText: 'Allow Permission',
              onGrantPermission: controller.requestContactsPermission,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Options Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Contacts',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF232530),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2C38), width: 1),
                  ),
                  child: TextField(
                    onChanged: controller.setSearchQuery,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search contacts...',
                      hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Contacts List
              Expanded(
                child: Obx(() {
                  final list = controller.displayedContacts;
                  if (list.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshContacts,
                      color: AppColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No contacts found',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshContacts,
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: list.length + (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == list.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ),
                          );
                        }
                        final c = list[index];
                        return _ContactCardItem(
                          name: c.name,
                          number: c.phoneNumber,
                          totalCalls: c.totalCalls,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ContactCardItem extends StatelessWidget {
  final String name;
  final String number;
  final int totalCalls;

  const _ContactCardItem({
    required this.name,
    required this.number,
    required this.totalCalls,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Initial Avatar + Name/Phone + Total Calls
          GestureDetector(
            onTap: () {
              Get.toNamed(
                AppRoutes.callDetails,
                arguments: CallLogItem(
                  id: UniqueKey().toString(),
                  name: name,
                  number: number,
                  type: CallType.incoming,
                  timestamp: DateTime.now(),
                  durationInSeconds: 120,
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                // Circular Initial Avatar with Gradient
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Contact Name & Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        number,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Total Calls Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Text(
                    'Calls: $totalCalls',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Action Row: Copy, Forum SMS, WhatsApp, Call
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => Get.find<ContactsController>().copyToClipboard(number),
                tooltip: 'Copy Number',
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 22,
                  color: Color(0xFF9EA3B8),
                ),
              ),
              IconButton(
                onPressed: () => Get.find<ContactsController>().sendSms(number),
                tooltip: 'SMS',
                icon: const Icon(
                  Icons.forum_outlined,
                  size: 22,
                  color: Color(0xFF3897F0),
                ),
              ),
              IconButton(
                onPressed: () => Get.find<ContactsController>().openWhatsApp(number),
                tooltip: 'WhatsApp',
                icon: Image.asset(
                  'assets/images/whatsapp.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 22,
                    color: Color(0xFF25D366),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.find<ContactsController>().makePhoneCall(number),
                tooltip: 'Call',
                icon: const Icon(
                  Icons.phone_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
