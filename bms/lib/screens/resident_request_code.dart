import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import '../widgets/resident_sidebar.dart';

void main() {
  runApp(const MaterialApp(home: DocumentRequest()));
}

class DocumentRequest extends StatelessWidget {
  const DocumentRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reasonController = TextEditingController();
  String _selectedDocumentType = 'Barangay Clearance';
  bool _isSaving = false;
  bool _isDraggingId = false;
  Uint8List? _idFileBytes;
  String? _idFileName;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    // DateTime normally supplies 1–12, but keeping this defensive avoids a
    // RangeError if a malformed date reaches this helper.
    if (month < 1 || month > months.length) {
      return '';
    }
    return months[month - 1];
  }

<<<<<<< HEAD
=======
  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'RN';
    final parts = clean.split(' ');
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  bool _isSupportedIdFile(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'pdf'}.contains(extension);
  }

  Future<void> _selectIdFile() async {
    final files = await file_picker.FilePicker.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _idFileBytes = bytes;
      _idFileName = file.name;
    });
  }

  Future<void> _useDroppedIdFile(XFile file) async {
    if (!_isSupportedIdFile(file.name)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please upload a JPG, PNG, or PDF identification file.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _idFileBytes = bytes;
      _idFileName = file.name;
    });
  }

  Future<void> _uploadIdAttachment({
    required DocumentReference<Map<String, dynamic>> requestRef,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final safeFileName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final attachmentRef = FirebaseStorage.instance.ref().child(
        'document_requests/${requestRef.id}/$safeFileName',
      );
      await attachmentRef.putData(fileBytes);
      final downloadUrl = await attachmentRef.getDownloadURL();
      await requestRef.update({
        'idAttachmentUrl': downloadUrl,
        'attachmentUploadStatus': 'uploaded',
        'attachmentUploadError': FieldValue.delete(),
      });
    } catch (_) {
      await requestRef.update({
        'attachmentUploadStatus': 'failed',
        'attachmentUploadError': 'ID attachment upload failed',
      });
    }
  }

>>>>>>> b54a044ce7e3c8d0c5826f7197d7ed4d6da67e03
  Future<void> _submitRequest() async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Reason for document.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final dateStr =
          '${_getMonthName(now.month)} ${now.day.toString().padLeft(2, '0')}, ${now.year}';

      final requestRef =
          FirebaseFirestore.instance.collection('document_requests').doc();
      final idFileBytes = _idFileBytes;
      final idFileName = _idFileName;

      await requestRef.set({
        'residentId': FirebaseAuth.instance.currentUser?.uid,
        'documentType': _selectedDocumentType,
        'dateSubmitted': dateStr,
<<<<<<< HEAD
        'residentName': 'Resident User',
        'initials': 'RU',
        'status': 'pending',
=======
        'residentName': name,
        'initials': _getInitials(name),
        'dateOfBirth': dob,
        'address': address,
        'status': 'Pending',
>>>>>>> b54a044ce7e3c8d0c5826f7197d7ed4d6da67e03
        'purpose': reason,
        'contactNumber': '',
        'idAttachmentName': idFileName,
        'idAttachmentUrl': null,
        'attachmentUploadStatus':
            idFileBytes == null ? 'not_provided' : 'uploading',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // The request appears in the admin database immediately. Uploading an
      // optional ID must not keep the resident waiting on the submit button.
      if (idFileBytes != null && idFileName != null) {
        unawaited(
          _uploadIdAttachment(
            requestRef: requestRef,
            fileBytes: idFileBytes,
            fileName: idFileName,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully submitted request for $_selectedDocumentType!',
            ),
            backgroundColor: const Color(0xFF002576),
          ),
        );
        _reasonController.clear();
        setState(() {
          _idFileBytes = null;
          _idFileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      bottomNavigationBar: !isDesktop ? _buildMobileBottomNav() : null,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildLeftColumn()),
                            const SizedBox(width: 24),
                            Expanded(flex: 5, child: _buildRightColumn()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildLeftColumn(),
                            const SizedBox(height: 24),
                            _buildRightColumn(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Document',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isDesktop ? 32 : 24,
                color: const Color(0xFF002576),
              ),
            ),
            const Text(
              'Submit Documents for Barangay Certifactions and permits online.',
              style: TextStyle(color: Color(0xFF444653)),
            ),
          ],
        ),
        if (isDesktop)
          OutlinedButton.icon(
            onPressed: () => _showPreviewDialog(context),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview Mode'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF002576),
              side: const BorderSide(color: Color(0xFF002576)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebar() {
    return const SizedBox(
      width: 256,
      child: ResidentSidebar(selectedItem: 'Document Request'),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        // Recent Announcements Table Card
        Card(
          elevation: 0,
          color: const Color(0xFFEFF4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC4C5D5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _filterChip('All', true),
                        _filterChip('Drafts', false),
                        _filterChip('Published', false),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAnnouncementListStream(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('View All History'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Stats Grid
      ],
    );
  }

  Widget _buildAnnouncementListStream() {
    // Filtering and ordering together requires a Firestore composite index.
    // Keep this small dashboard feed index-free by sorting the streamed data
    // after it reaches the client.
    final stream =
        FirebaseFirestore.instance.collection('announcements').snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final docs =
            (snapshot.data?.docs ?? [])
                .where((doc) => doc.data()['status'] == 'published')
                .toList();
        docs.sort((a, b) {
          final aCreatedAt = a.data()['createdAt'];
          final bCreatedAt = b.data()['createdAt'];
          final aMillis =
              aCreatedAt is Timestamp ? aCreatedAt.millisecondsSinceEpoch : 0;
          final bMillis =
              bCreatedAt is Timestamp ? bCreatedAt.millisecondsSinceEpoch : 0;
          return bMillis.compareTo(aMillis);
        });
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No announcements published yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children:
              docs.map((doc) {
                final data = doc.data();
                final title = data['title'] ?? '';
                final desc = data['description'] ?? 'No details provided.';
                final date = data['date'] ?? '';
                final categoryName = data['category'] ?? 'news';

                Color catColor = const Color(0xFF0038A8);
                if (categoryName == 'emergency')
                  catColor = const Color(0xFFDC2626);
                if (categoryName == 'event') catColor = const Color(0xFF15803D);

                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFC4C5D5), width: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0038A8),
                              ),
                            ),
                            Text(
                              desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(date, style: const TextStyle(fontSize: 12)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            color: catColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildRightColumn() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF002576),
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Document Form',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.assignment, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Document Type'),
                DropdownButtonFormField<String>(
                  value: _selectedDocumentType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Barangay Clearance',
                      child: Text('Barangay Clearance'),
                    ),
                    DropdownMenuItem(
                      value: 'Certificate of Residency',
                      child: Text('Certificate of Residency'),
                    ),
                    DropdownMenuItem(
                      value: 'Business Permit',
                      child: Text('Business Permit'),
                    ),
                    DropdownMenuItem(
                      value: 'Indigency Certificate',
                      child: Text('Indigency Certificate'),
                    ),
                    DropdownMenuItem(
                      value: 'Barangay ID',
                      child: Text('Barangay ID'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDocumentType = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Reason for Request / Purpose'),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe why you are requesting this document...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildUploadArea(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSaving
                                ? null
                                : () {
                                  _reasonController.clear();
                                  setState(() {
                                    _idFileBytes = null;
                                    _idFileName = null;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Form cleared!'),
                                    ),
                                  );
                                },
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Clear Form'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002576),
                          foregroundColor: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Submit Request'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF444653),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDraggingId = true),
      onDragExited: (_) => setState(() => _isDraggingId = false),
      onDragDone: (details) async {
        setState(() => _isDraggingId = false);
        if (details.files.isNotEmpty) {
          await _useDroppedIdFile(details.files.first);
        }
      },
      child: GestureDetector(
        onTap: _selectIdFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  _isDraggingId
                      ? const Color(0xFF002576)
                      : const Color(0xFFC4C5D5),
              width: _isDraggingId ? 2 : 1,
            ),
            color:
                _isDraggingId
                    ? const Color(0xFFDCE9FF)
                    : const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                _idFileBytes == null
                    ? Icons.cloud_upload_outlined
                    : Icons.check_circle_outline,
                size: 48,
                color: const Color(0xFF747685),
              ),
              const SizedBox(height: 8),
              Text(
                _idFileName ?? 'Drop ID here or click to upload',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'JPG, PNG, or PDF',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: textColor.withOpacity(0.5), size: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
        backgroundColor:
            isSelected ? const Color(0xFFD3E4FE) : Colors.transparent,
        side: BorderSide.none,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedItemColor: const Color(0xFF735C00),
      unselectedItemColor: const Color(0xFF444653),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 500,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF002576),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'EVENT',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Annual Community Clean-up',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002576),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join your fellow residents this coming Saturday as we revitalize our community spaces. Tools and refreshments provided.',
                          style: TextStyle(color: Color(0xFF444653)),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF002576)),
                              SizedBox(width: 12),
                              Text(
                                'Main Barangay Plaza',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002576),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Confirm Participation'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
