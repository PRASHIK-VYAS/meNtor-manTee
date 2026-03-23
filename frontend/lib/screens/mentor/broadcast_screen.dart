import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/broadcast_model.dart';
import '../../providers/mentor_provider.dart';
import 'package:intl/intl.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _urgencyLevel = 'Normal';
  BroadcastModel? _editingBroadcast;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    if (_formKey.currentState!.validate()) {
      final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
      final mentorId = mentorProvider.currentMentor?.id ?? '';

      if (_editingBroadcast != null) {
        final updated = _editingBroadcast!.copyWith(
          title: _titleController.text,
          message: _messageController.text,
          isUrgent: _urgencyLevel == 'High',
          date: DateTime.now(), // Update date to now on edit? Or keep? User said "stored in history", usually implies last modified.
        );
        await mentorProvider.updateBroadcast(updated);
        setState(() {
          _editingBroadcast = null;
          _titleController.clear();
          _messageController.clear();
          _urgencyLevel = 'Normal';
        });
        _tabController.animateTo(1); // Go to history
      } else {
        final broadcast = BroadcastModel(
          id: '', // Backend will assign integer ID
          mentorId: mentorId,
          title: _titleController.text,
          message: _messageController.text,
          date: DateTime.now(),
          isUrgent: _urgencyLevel == 'High',
        );
        await mentorProvider.sendBroadcast(broadcast);
        _titleController.clear();
        _messageController.clear();
        _urgencyLevel = 'Normal';
        _tabController.animateTo(1); // Go to history
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingBroadcast != null ? 'Broadcast updated!' : 'Broadcast sent to all mentees!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _editBroadcast(BroadcastModel broadcast) {
    setState(() {
      _editingBroadcast = broadcast;
      _titleController.text = broadcast.title;
      _messageController.text = broadcast.message;
      _urgencyLevel = broadcast.isUrgent ? 'High' : 'Normal';
    });
    _tabController.animateTo(0); // Go to compose
  }

  void _deleteBroadcast(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Broadcast?'),
        content: const Text('This will remove it from all student histories.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<MentorProvider>(context, listen: false).deleteBroadcast(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'COMPOSE', icon: Icon(Icons.edit_note)),
              Tab(text: 'HISTORY', icon: Icon(Icons.history_edu)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildComposeTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComposeTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingBroadcast != null ? 'Editing existing broadcast.' : 'Announce to all assigned students.',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (_editingBroadcast != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingBroadcast = null;
                          _titleController.clear();
                          _messageController.clear();
                        });
                      },
                      child: const Text('Cancel Edit'),
                    )
                ],
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('TITLE'),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Batch Meeting Reminder',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('MESSAGE'),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter a message' : null,
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('PRIORITY'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Normal', label: Text('Normal'), icon: Icon(Icons.notifications_outlined)),
                  ButtonSegment(value: 'High', label: Text('Urgent'), icon: Icon(Icons.warning_amber_rounded)),
                ],
                selected: {_urgencyLevel},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _urgencyLevel = newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: _urgencyLevel == 'High' ? Colors.red.shade50 : Colors.black,
                  selectedForegroundColor: _urgencyLevel == 'High' ? Colors.red : Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _handleSend,
                icon: Icon(_editingBroadcast != null ? Icons.save_rounded : Icons.send_rounded),
                label: Text(_editingBroadcast != null ? 'Save Changes' : 'Post Broadcast'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<MentorProvider>(
      builder: (context, provider, child) {
        final history = provider.broadcasts;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No broadcast history found.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final broadcast = history[index];
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (broadcast.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                            child: const Text('URGENT', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        else
                          const SizedBox.shrink(),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(broadcast.date),
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(broadcast.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(broadcast.message, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionIcon(Icons.edit_outlined, Colors.blue, () => _editBroadcast(broadcast)),
                        const SizedBox(width: 12),
                        _buildActionIcon(Icons.delete_outline_rounded, Colors.red, () => _deleteBroadcast(broadcast.id)),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0, color: Colors.black54),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
