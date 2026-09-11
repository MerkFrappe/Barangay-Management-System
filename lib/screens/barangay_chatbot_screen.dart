import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';

class BarangayChatbotScreen extends StatefulWidget {
  const BarangayChatbotScreen({super.key});

  @override
  State<BarangayChatbotScreen> createState() => _BarangayChatbotScreenState();
}

class _BarangayChatbotScreenState extends State<BarangayChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Good day! I’m the Barangay Digital Assistant. I can help with documents, requests, services, and common barangay questions.',
      isUser: false,
    ),
  ];
  bool _showPermitQuestions = false;
  bool _showRequestedDocuments = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? value]) {
    final message = (value ?? _messageController.text).trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _messages.add(_ChatMessage(text: _replyFor(message), isUser: false));
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPermitsAndDocuments() {
    setState(() {
      _showPermitQuestions = true;
      _showRequestedDocuments = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showRequestTracker() {
    setState(() {
      _showRequestedDocuments = true;
      _showPermitQuestions = false;
    });
  }

  String _replyFor(String message) {
    final query = message.toLowerCase();
    if (query.contains('difference') &&
        query.contains('residency') &&
        query.contains('clearance')) {
      return 'A Certificate of Residency confirms that you live in the barangay. A Barangay Clearance is commonly used for employment, business, permits, and other official transactions after barangay verification.';
    }
    if (query.contains('business clearance')) {
      return 'To get a Barangay Business Clearance, visit Barangay Hall with your valid ID, business registration (DTI or SEC), proof of business location, and other documents requested for site verification.';
    }
    if (query.contains('certificate of indigency') ||
        query.contains('indigency')) {
      return 'To obtain a Certificate of Indigency, visit Barangay Hall with a valid ID or Purok Clearance and state the purpose of the certificate. The barangay may verify your details before issuance.';
    }
    if (query.contains('track') || query.contains('request status')) {
      return 'You can check your document request status from Document Request. Keep your reference number ready.';
    }
    if (query.contains('clearance') || query.contains('document')) {
      return 'For a Barangay Clearance, prepare a valid ID or Purok Clearance, cedula, and the required fee. Processing usually takes 1–2 business days.';
    }
    if (query.contains('residency') || query.contains('indigency')) {
      return 'A Certificate of Residency needs a valid ID or Purok Clearance and proof of address. For an Indigency Certificate, please state its purpose; an officer may verify the details.';
    }
    if (query.contains('business') || query.contains('permit')) {
      return 'For a business endorsement, visit Barangay Hall with your Barangay Clearance, DTI/SEC registration, proof of location, and valid ID for site verification.';
    }
    if (query.contains('hour') || query.contains('open')) {
      return 'Barangay Hall is open Monday to Friday, 8:00 AM to 5:00 PM.';
    }
    if (query.contains('contact') || query.contains('hotline')) {
      return 'You may reach the barangay through +63 917 123 4567 or help@barangay.gov.ph.';
    }
    return 'I can help with document requirements, request tracking, barangay services, office hours, and contact information. What would you like to know?';
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1100;
    final compact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop
          ? null
          : const Drawer(
              child: ResidentSidebar(selectedItem: 'Barangay ChatBot'),
            ),
      bottomNavigationBar: desktop
          ? null
          : const ResidentMobileNavigation(currentIndex: 0),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              const ResidentSidebar(selectedItem: 'Barangay ChatBot'),
            Expanded(
              child: Column(
                children: [
                  const TopNavigationBar(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.all(compact ? 12 : 32),
                          child: _ChatPanel(
                            compact: compact,
                            messages: _messages,
                            controller: _messageController,
                            scrollController: _scrollController,
                            onSend: _sendMessage,
                            showPermitQuestions: _showPermitQuestions,
                            onShowPermitsAndDocuments: _showPermitsAndDocuments,
                            showRequestedDocuments: _showRequestedDocuments,
                            onShowRequestTracker: _showRequestTracker,
                            onBackToOptions: () => setState(() {
                              _showPermitQuestions = false;
                              _showRequestedDocuments = false;
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final bool compact;
  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final ValueChanged<String> onSend;
  final bool showPermitQuestions;
  final VoidCallback onShowPermitsAndDocuments;
  final bool showRequestedDocuments;
  final VoidCallback onShowRequestTracker;
  final VoidCallback onBackToOptions;

  const _ChatPanel({
    required this.compact,
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onSend,
    required this.showPermitQuestions,
    required this.onShowPermitsAndDocuments,
    required this.showRequestedDocuments,
    required this.onShowRequestTracker,
    required this.onBackToOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 18 : 24,
              20,
              compact ? 18 : 24,
              18,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barangay ChatBot',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Official Resident Assistant',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Online',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.all(compact ? 16 : 24),
              children: [
                ...messages.map((message) => _MessageBubble(message: message)),
                const SizedBox(height: 8),
                Text(
                  'Try a quick question',
                  style: AppTextStyles.titleSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                if (!showPermitQuestions && !showRequestedDocuments)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickPrompt(
                        icon: Icons.description_outlined,
                        label: 'Permits & Document Issuances',
                        onTap: onShowPermitsAndDocuments,
                      ),
                      _QuickPrompt(
                        icon: Icons.manage_search_outlined,
                        label: 'Track my request',
                        onTap: onShowRequestTracker,
                      ),
                      _QuickPrompt(
                        icon: Icons.account_balance_outlined,
                        label: 'Barangay services',
                        onTap: () =>
                            onSend('What barangay services are available?'),
                      ),
                      _QuickPrompt(
                        icon: Icons.help_outline_rounded,
                        label: 'Ask a question',
                        onTap: () => onSend('What are the office hours?'),
                      ),
                    ],
                  ),
                if (showPermitQuestions) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Permits & Document Issuances',
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DocumentQuestion(
                    label:
                        'How do I apply for a Barangay Clearance or Barangay Certificate?',
                    onTap: () => onSend(
                      'How do I apply for a Barangay Clearance or Barangay Certificate?',
                    ),
                  ),
                  _DocumentQuestion(
                    label:
                        'What is the difference between a Barangay Certificate of Residency and a Barangay Clearance?',
                    onTap: () => onSend(
                      'What is the difference between a Barangay Certificate of Residency and a Barangay Clearance?',
                    ),
                  ),
                  _DocumentQuestion(
                    label: 'How do I get a Barangay Business Clearance?',
                    onTap: () =>
                        onSend('How do I get a Barangay Business Clearance?'),
                  ),
                  _DocumentQuestion(
                    label: 'How can I obtain a Certificate of Indigency?',
                    onTap: () =>
                        onSend('How can I obtain a Certificate of Indigency?'),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onBackToOptions,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to assistant options'),
                    ),
                  ),
                ],
                if (showRequestedDocuments) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Requested Documents',
                          style: AppTextStyles.titleMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onBackToOptions,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const _RequestedDocumentsList(),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(compact ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: onSend,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                suffixIcon: IconButton(
                  tooltip: 'Send message',
                  onPressed: () => onSend(controller.text),
                  icon: const Icon(Icons.send_rounded),
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.primary
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: message.isUser ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickPrompt({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _DocumentQuestion extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DocumentQuestion({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestedDocumentsList extends StatelessWidget {
  const _RequestedDocumentsList();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Sign in to view your requested documents.'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('document_requests')
          .where('residentId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Unable to load your document requests right now.'),
          );
        }

        final requests = snapshot.data?.docs.toList() ?? [];
        requests.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];
          final aMillis = aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
          final bMillis = bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;
          return bMillis.compareTo(aMillis);
        });

        if (requests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No document requests submitted yet.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          );
        }

        return Column(
          children: requests.take(5).map((request) {
            final data = request.data();
            final documentType = (data['documentType'] ?? 'Document')
                .toString();
            final date = (data['dateSubmitted'] ?? 'Date unavailable')
                .toString();
            final status = (data['status'] ?? 'pending').toString();
            return _RequestedDocumentCard(
              documentType: documentType,
              date: date,
              status: status,
            );
          }).toList(),
        );
      },
    );
  }
}

class _RequestedDocumentCard extends StatelessWidget {
  final String documentType;
  final String date;
  final String status;

  const _RequestedDocumentCard({
    required this.documentType,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final color = normalizedStatus == 'rejected'
        ? AppColors.error
        : normalizedStatus == 'finished' || normalizedStatus == 'released'
        ? AppColors.successGreen
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(documentType, style: AppTextStyles.titleSm),
                const SizedBox(height: 2),
                Text(
                  'Submitted $date',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}
