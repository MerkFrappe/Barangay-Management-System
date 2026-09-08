import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type;
  final String referenceId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final timestamp = data['createdAt'];
    return AppNotification(
      id: document.id,
      type: (data['type'] ?? '').toString(),
      referenceId: (data['referenceId'] ?? '').toString(),
      title: (data['title'] ?? 'Notification').toString(),
      body: (data['body'] ?? '').toString(),
      isRead: data['isRead'] == true,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
