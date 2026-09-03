import '../models/call_log_model.dart';
import '../models/call_stats_model.dart';
import '../models/contact_model.dart';

class MockCallLogService {
  static List<CallLogItem> getMockCallLogs() {
    final now = DateTime.now();
    final namesAndNumbers = [
      {'name': 'KUSHAL ASODIA Flutter', 'number': '+919978217711', 'tag': CallTag.work, 'note': 'Discussed Flutter App Architecture'},
      {'name': 'Jhuni Fua', 'number': '+917070121461', 'tag': CallTag.personal, 'note': 'Family greeting call'},
      {'name': 'Bhabhi', 'number': '+919905608748', 'tag': CallTag.personal, 'note': 'Tap here to add notes'},
      {'name': 'Rahul Sharma', 'number': '+919825012345', 'tag': CallTag.lead, 'note': 'Interested in CRM module'},
      {'name': 'Amit Patel', 'number': '+919876543210', 'tag': CallTag.spam, 'note': 'Telemarketing loan call'},
      {'name': 'Priya Verma', 'number': '+919712345678', 'tag': CallTag.lead, 'note': 'Follow up requested on Monday'},
      {'name': 'Suresh Kumar', 'number': '+919456789012', 'tag': CallTag.support, 'note': 'Resolved support ticket #402'},
      {'name': 'Vikram Singh', 'number': '+919811122233', 'tag': CallTag.work, 'note': 'Sprint demo review'},
      {'name': 'Ananya Roy', 'number': '+919722233344', 'tag': CallTag.lead, 'note': 'Requested price quote'},
      {'name': 'Rohan Mehta', 'number': '+919633344455', 'tag': CallTag.work, 'note': 'Code review session'},
      {'name': 'Sneha Gupta', 'number': '+919544455566', 'tag': CallTag.personal, 'note': 'Birthday wishes'},
      {'name': 'Manish Joshi', 'number': '+919455566677', 'tag': CallTag.lead, 'note': 'Needs onboarding call'},
      {'name': 'Deepak Malhotra', 'number': '+919366677788', 'tag': CallTag.work, 'note': 'Backend API integration'},
      {'name': 'Kavita Reddy', 'number': '+919277788899', 'tag': CallTag.support, 'note': 'Account configuration query'},
      {'name': 'Siddharth Rao', 'number': '+919188899900', 'tag': CallTag.work, 'note': 'Project milestone planning'},
      {'name': 'Pooja Agarwal', 'number': '+919099900011', 'tag': CallTag.personal, 'note': 'Dinner plans'},
      {'name': 'Gaurav Kapoor', 'number': '+919900011122', 'tag': CallTag.lead, 'note': 'Enterprise demo scheduled'},
      {'name': 'Neha Saxena', 'number': '+919811100099', 'tag': CallTag.work, 'note': 'UI Design sign-off'},
      {'name': 'Rajesh Khanna', 'number': '+919722200088', 'tag': CallTag.spam, 'note': 'Insurance telecaller'},
      {'name': 'Divya Nair', 'number': '+919633300077', 'tag': CallTag.support, 'note': 'Password reset request'},
    ];

    final callTypes = [
      CallType.incoming,
      CallType.outgoing,
      CallType.missed,
      CallType.rejected,
      CallType.neverAttended,
      CallType.notPickupByClient,
    ];

    final List<CallLogItem> logs = [];

    // Generate 40 detailed mock call logs spanning the last few days
    for (int i = 0; i < 40; i++) {
      final info = namesAndNumbers[i % namesAndNumbers.length];
      final type = callTypes[i % callTypes.length];
      final minutesAgo = i * 25 + 5;
      final time = now.subtract(Duration(minutes: minutesAgo));
      final duration = (type == CallType.incoming || type == CallType.outgoing) ? (i * 47 + 18) : 0;

      final String simId = '1';

      logs.add(
        CallLogItem(
          id: 'mock_log_${i + 1}',
          name: info['name'] as String,
          number: info['number'] as String,
          type: type,
          timestamp: time,
          durationInSeconds: duration,
          simId: simId,
          tag: info['tag'] as CallTag,
          note: info['note'] as String,
        ),
      );
    }

    return logs;
  }

  static CallStatsModel getMockCallStats() {
    final logs = getMockCallLogs();
    int incomingCount = 0;
    int outgoingCount = 0;
    int missedCount = 0;
    int rejectedCount = 0;
    int totalSecs = 0;
    int incSecs = 0;
    int outSecs = 0;

    for (var log in logs) {
      totalSecs += log.durationInSeconds;
      switch (log.type) {
        case CallType.incoming:
          incomingCount++;
          incSecs += log.durationInSeconds;
          break;
        case CallType.outgoing:
          outgoingCount++;
          outSecs += log.durationInSeconds;
          break;
        case CallType.missed:
          missedCount++;
          break;
        case CallType.rejected:
        case CallType.neverAttended:
        case CallType.notPickupByClient:
          rejectedCount++;
          break;
      }
    }

    return CallStatsModel(
      totalCalls: logs.length,
      incomingCount: incomingCount,
      outgoingCount: outgoingCount,
      missedCount: missedCount,
      rejectedCount: rejectedCount,
      neverAttendedCount: 5,
      notPickupByClientCount: 3,
      uniqueCallsCount: 15,
      totalDurationSeconds: totalSecs,
      incomingDurationSeconds: incSecs,
      outgoingDurationSeconds: outSecs,
      topCallerName: 'KUSHAL ASODIA Flutter',
      topCallerNumber: '+919978217711',
      topCallerCount: 12,
    );
  }

  static List<ContactItem> getMockContacts() {
    final now = DateTime.now();
    final namesAndNumbers = [
      {'name': 'KUSHAL ASODIA Flutter', 'number': '+919978217711', 'email': 'kushal@flutter.dev', 'company': 'Flutter Devs'},
      {'name': 'Jhuni Fua', 'number': '+917070121461', 'email': 'jhuni@family.com', 'company': 'Personal'},
      {'name': 'Bhabhi', 'number': '+919905608748', 'email': 'bhabhi@family.com', 'company': 'Personal'},
      {'name': 'Rahul Sharma', 'number': '+919825012345', 'email': 'rahul@techcorp.com', 'company': 'Tech Corp'},
      {'name': 'Amit Patel', 'number': '+919876543210', 'email': 'amit@finance.org', 'company': 'Finance Ltd'},
      {'name': 'Priya Verma', 'number': '+919712345678', 'email': 'priya@designhub.io', 'company': 'Design Hub'},
      {'name': 'Suresh Kumar', 'number': '+919456789012', 'email': 'suresh@logistics.com', 'company': 'Logistics Pro'},
      {'name': 'Vikram Singh', 'number': '+919811122233', 'email': 'vikram@innovate.co', 'company': 'Innovate Inc'},
      {'name': 'Ananya Roy', 'number': '+919722233344', 'email': 'ananya@creatives.com', 'company': 'Creatives'},
      {'name': 'Rohan Mehta', 'number': '+919633344455', 'email': 'rohan@solutions.in', 'company': 'Solutions Ltd'},
      {'name': 'Sneha Gupta', 'number': '+919544455566', 'email': 'sneha@mediaworks.net', 'company': 'MediaWorks'},
      {'name': 'Manish Joshi', 'number': '+919455566677', 'email': 'manish@buildcon.org', 'company': 'BuildCon'},
      {'name': 'Deepak Malhotra', 'number': '+919366677788', 'email': 'deepak@cloudsystems.com', 'company': 'Cloud Systems'},
      {'name': 'Kavita Reddy', 'number': '+919277788899', 'email': 'kavita@healthplus.org', 'company': 'Health Plus'},
      {'name': 'Siddharth Rao', 'number': '+919188899900', 'email': 'siddharth@ventures.com', 'company': 'Ventures Group'},
      {'name': 'Pooja Agarwal', 'number': '+919099900011', 'email': 'pooja@educate.edu', 'company': 'Educate Global'},
      {'name': 'Gaurav Kapoor', 'number': '+919900011122', 'email': 'gaurav@retail chain.com', 'company': 'Retail Chain'},
      {'name': 'Neha Saxena', 'number': '+919811100099', 'email': 'neha@studios.io', 'company': 'Studio X'},
      {'name': 'Rajesh Khanna', 'number': '+919722200088', 'email': 'rajesh@automotive.in', 'company': 'Auto World'},
      {'name': 'Divya Nair', 'number': '+919633300077', 'email': 'divya@biotech.com', 'company': 'BioTech Labs'},
    ];

    final List<ContactItem> contacts = [];
    for (int i = 0; i < 35; i++) {
      final info = namesAndNumbers[i % namesAndNumbers.length];
      contacts.add(
        ContactItem(
          id: 'mock_contact_${i + 1}',
          name: i >= namesAndNumbers.length ? '${info['name']} ${i + 1}' : info['name'] as String,
          phoneNumber: info['number'] as String,
          email: info['email'] as String,
          company: info['company'] as String,
          totalCalls: (i * 3 + 4) % 25 + 1,
          lastCallTime: now.subtract(Duration(hours: i * 3 + 1)),
        ),
      );
    }

    return contacts;
  }
}
