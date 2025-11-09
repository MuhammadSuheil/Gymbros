import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../tracking/viewmodel/workout_viewmodel.dart';
import '../../../core/widgets/dialogs.dart';
import 'package:gymbros/core/constants/app_colors.dart'; 
import '../../main_screen/main_screen.dart';
import '../../history/viewmodel/history_viewmodel.dart';
import '../../streak/viewmodel/streak_viewmodel.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> setsData;
  final Duration duration;
  final DateTime sessionStartTime;

  const WorkoutSummaryScreen({
    super.key,
    required this.setsData,
    required this.duration,
    required this.sessionStartTime,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final _notesController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _bodyWeightController.dispose();
    super.dispose();
  }

  void _saveFinalSession(BuildContext context) async {
     if (!_formKey.currentState!.validate()) { return; }

    final viewModel = Provider.of<WorkoutViewModel>(context, listen: false);
    viewModel.resetErrorState();

    final String notes = _notesController.text.trim();
    final double? bodyWeight = double.tryParse(
        _bodyWeightController.text.trim().replaceAll(',', '.')
    );
    print("[SummaryScreen] Values read from controllers:");
    print("  Notes: '$notes'"); 
    print("  BodyWeight (parsed): $bodyWeight");
    print("[SummaryScreen] Saving session with notes: $notes, bodyWeight: $bodyWeight");

    bool success = await viewModel.saveWorkoutSession(
      setsData: widget.setsData,
      duration: widget.duration,
      sessionStartTime: widget.sessionStartTime,
      notes: notes.isNotEmpty ? notes : null,
      bodyWeight: bodyWeight,
    );

    if (success && mounted) {
      print("[SummaryScreen] Notifying other view models to refresh...");
      await context.read<HistoryViewModel>().fetchHistory();
      await context.read<StreakViewModel>().fetchAllStreakData();

      final bool? result = await showInfoPopup(
        context,
        'Success!',
        'Your workout session has been saved successfully.',
      );
      
      if (result == true && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (!success && mounted) {
      showErrorPopup(context, 'Save Failed', viewModel.errorMessage);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

   String _getExercisesSummary() {
      if (widget.setsData.isEmpty) return 'No exercises';
      final exerciseNames = widget.setsData.map((set) => set['exerciseName'] as String? ?? 'N/A').toSet().take(5).join(', ');
      return exerciseNames;
   }

  @override
  Widget build(BuildContext context) {
     final viewModel = context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Summary',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Date:', DateFormat('EEEE, d MMM yyyy', 'en_US').format(widget.sessionStartTime)),
                      _buildSummaryRow('Start Time:', DateFormat('HH:mm', 'en_US').format(widget.sessionStartTime)),
                      _buildSummaryRow('Duration:', _formatDuration(widget.duration)),
                      _buildSummaryRow('Total Sets:', widget.setsData.length.toString()),
                      _buildSummaryRow('Exercises:', _getExercisesSummary()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Additional Info (Optional)',
                 style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes',
                  hintText: 'How did it feel? Any PRs?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              TextFormField(
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: _bodyWeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Body Weight (kg)',
                  hintText: 'Example: 75.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')),
                ],
                 validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final weight = double.tryParse(value.replaceAll(',', '.'));
                    if (weight == null) {
                       return 'Enter a valid number!'; 
                    }
                    if (weight <= 0) {
                       return 'Invalid Bodyweight'; 
                    }
                    return null;
                 },
              ), 
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: viewModel.state == ViewState.Loading ? null : () => _saveFinalSession(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: viewModel.state == ViewState.Loading
                  ? const CircularProgressIndicator(color: Colors.white,)
                  : const Text('Save Workout Session'), 
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSecondary,)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: AppColors.onPrimary),)),
        ],
      ),
    );
  }
}

