import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near2me/agent/suggestion_agent.dart';
import 'package:near2me/models/agent_context.dart';
import 'package:near2me/screens/map_picker_screen.dart';
import 'package:near2me/widgets/suggestion_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedTime;
  String? _selectedLocation;
  String? _suggestion;
  bool _loading = false;

  final SuggestionAgent _agent = SuggestionAgent();

  void _selectTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      final formatted = DateFormat.jm().format(
        DateTime(0, 0, 0, picked.hour, picked.minute),
      );
      setState(() {
        _selectedTime = formatted;
      });
    }
  }

  void _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPickerScreen()),
    );
    if (result != null && result is String) {
      setState(() => _selectedLocation = result);
    }
  }

  void _getSuggestion() async {
    if (_selectedLocation == null || _selectedTime == null) return;
    setState(() {
      _loading = true;
      _suggestion = null;
    });

    final contextObj = AgentContext(
      timeOfDay: _selectedTime!,
      locationDescription: _selectedLocation!,
    );

    final suggestion = await _agent.getSuggestion(contextObj);
    setState(() {
      _suggestion = suggestion;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local Spot'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: _selectLocation,
                  child: Text(_selectedLocation ?? "Select Location"),
                ),
                SizedBox(width: 12),
                FilledButton(
                  onPressed: _selectTime,
                  child: Text(_selectedTime ?? "Select Time"),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getSuggestion,
              icon: Icon(Icons.lightbulb),
              label: Text("Local Spot Suggestion"),
            ),
            SizedBox(height: 24),
            if (_loading) CircularProgressIndicator(),
            if (_suggestion != null) SuggestionCard(text: _suggestion!),
          ],
        ),
      ),
    );
  }
}
