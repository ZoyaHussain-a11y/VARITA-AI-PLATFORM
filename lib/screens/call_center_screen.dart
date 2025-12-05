import 'package:flutter/material.dart';

// Reuse constants
const Color kPrimaryColor = Color(0xFFC80469);
const Color kHeaderColor = Color(0xFFC80469);
const Color kBackgroundColor = Color(0xFFF7F7F7);
const Color kUrgentColor = Color(0xFFC80469); // Red for urgent
const Color kFollowUpColor = Color(0xFFFFB300); // Amber for follow-up
const Color kRoutineColor = Color(0xFF43A047); // Green for routine

// Data model for a Pending Call
class PendingCall {
  final String id;
  final String patientName;
  final String phoneNumber;
  final String reason;
  final DateTime timeLogged;
  final CallPriority priority;
  final String patientImageUrl;

  PendingCall({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.reason,
    required this.timeLogged,
    required this.priority,
    required this.patientImageUrl,
  });
}

enum CallPriority { urgent, followUp, routine }

// Mock Data
final List<PendingCall> mockCalls = [
  PendingCall(
    id: 'C001',
    patientName: 'Khadija Ahmed',
    phoneNumber: '+92 333 1234567',
    reason: 'Severe Chest Pain',
    timeLogged: DateTime.now().subtract(const Duration(minutes: 15)),
    priority: CallPriority.urgent,
    patientImageUrl: 'https://i.ibb.co/t3p2y3Q/khadija-ahmed.jpg',
  ),
  PendingCall(
    id: 'C002',
    patientName: 'Jane Smith',
    phoneNumber: '+92 300 9876543',
    reason: 'Medication Refill Request',
    timeLogged: DateTime.now().subtract(const Duration(hours: 1)),
    priority: CallPriority.followUp,
    patientImageUrl: 'https://i.ibb.co/y4pLg6s/jane-smith.jpg',
  ),
  PendingCall(
    id: 'C003',
    patientName: 'Fatima Ali',
    phoneNumber: '+92 312 2468135',
    reason: 'Appointment Confirmation',
    timeLogged: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
    priority: CallPriority.routine,
    patientImageUrl: 'https://i.ibb.co/N1pX5G4/fatima-ali.jpg',
  ),
  PendingCall(
    id: 'C004',
    patientName: 'Talia Arshad',
    phoneNumber: '+92 345 5554443',
    reason: 'Lab Test Results Follow-up',
    timeLogged: DateTime.now().subtract(const Duration(hours: 5)),
    priority: CallPriority.followUp,
    patientImageUrl: 'https://i.ibb.co/P47z9Jt/talia-arshad.jpg', // Mock image
  ),
];

class CallCenterScreen extends StatefulWidget {
  const CallCenterScreen({super.key});

  @override
  State<CallCenterScreen> createState() => _CallCenterScreenState();
}

class _CallCenterScreenState extends State<CallCenterScreen> {
  String _searchQuery = '';
  CallPriority? _filterPriority;

  // Function to get the color based on priority
  Color _getPriorityColor(CallPriority priority) {
    switch (priority) {
      case CallPriority.urgent:
        return kUrgentColor;
      case CallPriority.followUp:
        return kFollowUpColor;
      case CallPriority.routine:
        return kRoutineColor;
    }
  }

  // Function to get the text based on priority
  String _getPriorityText(CallPriority priority) {
    switch (priority) {
      case CallPriority.urgent:
        return 'Urgent';
      case CallPriority.followUp:
        return 'Follow-up';
      case CallPriority.routine:
        return 'Routine';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort and filter the calls
    List<PendingCall> filteredCalls = mockCalls.where((call) {
      final nameMatches = call.patientName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final reasonMatches = call.reason.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final priorityMatches =
          _filterPriority == null || call.priority == _filterPriority;
      return (nameMatches || reasonMatches) && priorityMatches;
    }).toList();

    // Custom sorting: Urgent first, then Follow-up, then Routine, then by time logged
    filteredCalls.sort((a, b) {
      // 1. Sort by Priority (Urgent > Follow-up > Routine)
      final priorityA = a.priority.index;
      final priorityB = b.priority.index;
      if (priorityA != priorityB) {
        return priorityA.compareTo(
          priorityB,
        ); // Because enum index is 0, 1, 2 (Urgent is 0)
      }
      // 2. Sort by Time Logged (Oldest first for the same priority)
      return a.timeLogged.compareTo(b.timeLogged);
    });

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Reused custom header structure
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Search and Filter Bar
          _buildSearchAndFilter(),

          // Pending Call Count Summary
          _buildSummaryCard(filteredCalls.length),

          // Call Queue List
          Expanded(
            child: filteredCalls.isEmpty
                ? const Center(
                    child: Text(
                      'No pending calls matching criteria.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    itemCount: filteredCalls.length,
                    itemBuilder: (context, index) {
                      return _buildCallCard(filteredCalls[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Custom AppBar ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0), // Higher than default
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 10,
          left: 10,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Call Center',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.settings, color: Colors.black54, size: 28),
          ],
        ),
      ),
    );
  }

  // --- Search and Filter Section ---
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          // Search Field
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search patient name or reason',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Priority Filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CallPriority.values.map((priority) {
              return _buildPriorityFilterChip(priority);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilterChip(CallPriority priority) {
    final bool isSelected = _filterPriority == priority;
    final color = _getPriorityColor(priority);
    final text = _getPriorityText(priority);

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterPriority = isSelected ? null : priority;
        });
      },
      child: Chip(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        backgroundColor: isSelected ? color.withOpacity(0.8) : Colors.grey[200],
        label: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        side: BorderSide(color: isSelected ? color : Colors.transparent),
      ),
    );
  }

  // --- Summary Card ---
  Widget _buildSummaryCard(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Total Pending Calls',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const Icon(Icons.headset_mic, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  // --- Individual Call Card ---
  Widget _buildCallCard(PendingCall call) {
    final priorityColor = _getPriorityColor(call.priority);
    final timeDifference = DateTime.now().difference(call.timeLogged);
    final timeAgo = timeDifference.inMinutes < 60
        ? '${timeDifference.inMinutes}m ago'
        : '${timeDifference.inHours}h ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: priorityColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Image
              ClipOval(
                child: Image.network(
                  call.patientImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: kPrimaryColor, size: 40),
                ),
              ),
              const SizedBox(width: 15),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.reason,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Priority and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: priorityColor, width: 1),
                    ),
                    child: Text(
                      _getPriorityText(call.priority),
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timeAgo,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 25),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                Icons.call,
                'Call Now',
                kPrimaryColor,
                () => print('Calling ${call.patientName}...'),
              ),
              _buildActionButton(
                context,
                Icons.mark_email_read,
                'Mark Done',
                kRoutineColor,
                () => print('Marking ${call.patientName} call as done.'),
              ),
              _buildActionButton(
                context,
                Icons.history,
                'View Record',
                Colors.blueGrey,
                () => print('Viewing record for ${call.patientName}.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
