import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbros/core/constants/app_colors.dart'; 
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../../data/models/exercise_model.dart';
import '../../../data/models/set_entry_model.dart';
import '../../../data/models/workout_group_model.dart';
import '../viewmodel/workout_viewmodel.dart';
import '../../exercise_selection/view/exercise_selection_screen.dart';
import '../../exercise_detail/view/exercise_detail_screen.dart';
import '../../workout_summary/view/workout_summary_screen.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/custom_page_route.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  const WorkoutTrackingScreen({super.key});

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  final List<WorkoutGroup> _workoutGroups = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  Duration _duration = Duration.zero;
  late DateTime _sessionStartTime;
  bool _isInitialized = false; 

  Timer? _restTimer;
  Duration _restDuration = const Duration(seconds: 90); 
  Duration _currentRestTime = Duration.zero;
  bool _isResting = false;
  
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();
  
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _minutesController.text = _restDuration.inMinutes.toString();
    _secondsController.text = _restDuration.inSeconds.remainder(60).toString();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService = context.read<NotificationService>(); 
       if (mounted) { 
          _startTimer();
          setState(() {
             _isInitialized = true; 
          });
       }
    });
    
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return; 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = Duration(seconds: _duration.inSeconds + 1);
        });
      } else {
         timer.cancel();
      }
    });
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _currentRestTime = _restDuration;
    _isResting = true;
    setState(() {});

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_currentRestTime.inSeconds > 0) {
           setState(() {
              _currentRestTime = Duration(seconds: _currentRestTime.inSeconds - 1);
           });
        } else {
          timer.cancel();
          _isResting = false;
          setState(() {});

          print("[NotificationService] Attempting to show rest finished notification...");
          _notificationService.showNotification(
            'Rest Finished!',
            'Time to start your next set!',
          );

          showInfoPopup(
            context, 
            "Rest Time's Up!", 
            "Get on to your next set!",
         );

          HapticFeedback.vibrate(); 
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRestTimer() {
     _restTimer?.cancel();
      _isResting = false;
      _currentRestTime = Duration.zero;
      if (mounted) setState(() {});
  }

  void _showEditRestTimerDialog() {
     // Set controller ke durasi saat ini
     _minutesController.text = _restDuration.inMinutes.toString();
     _secondsController.text = _restDuration.inSeconds.remainder(60).toString();

     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20) ),
           title: Center(child: const Text('Set Rest Duration', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700),)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 40),
                        controller: _minutesController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          filled: true,                
                          fillColor: AppColors.background,   
                          border: OutlineInputBorder(    
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.transparent, 
                            ),
                          ),
                          ),  
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(':', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.onPrimary)),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 40),
                        controller: _secondsController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Sec',
                          filled: true,                
                          fillColor: AppColors.background,   
                          border: OutlineInputBorder(    
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.transparent, 
                            ),
                          ),
                          ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(),
               child: const Text('Cancel'),
             ),
             TextButton(
               style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary
               ),

               onPressed: () {
                 final int minutes = int.tryParse(_minutesController.text) ?? 0;
                 final int seconds = int.tryParse(_secondsController.text) ?? 0;
                 if (mounted) {
                    setState(() {
                       _restDuration = Duration(minutes: minutes, seconds: seconds);
                    });
                 }
                  Navigator.of(context).pop();
               },
               child: const Text('Set'),
             ),
           ],
         );
       },
     );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
  void _navigateAndAddExercise() async {
    final selectedExercise = await Navigator.push<ExerciseModel>(
      context,
      CustomPageRoute(
        child: const ExerciseSelectionScreen(),
        direction: AxisDirection.up, 
      ),
    );

    if (selectedExercise != null && mounted) {
      bool groupExists = _workoutGroups.any((group) => group.exercise.id == selectedExercise.id);
      if (groupExists) {
        showInfoPopup(
        context, 
        'Exercise Already Added', 
        '${selectedExercise.name} is already in your list. Adding another set instead.'
      );
         int lastIndex = _workoutGroups.lastIndexWhere((group) => group.exercise.id == selectedExercise.id);
         WorkoutGroup targetGroup = _workoutGroups.firstWhere((group) => group.exercise.id == selectedExercise.id);
         _addSetToGroup(targetGroup);

      } else {
        setState(() {
          _workoutGroups.add(WorkoutGroup(exercise: selectedExercise));
        });
      }
    }
  }
  void _addSetToGroup(WorkoutGroup group) {
     if (mounted) {
       setState(() {
         group.sets.add(SetEntry());
       });
     }
  }
  void _deleteSetFromGroup(WorkoutGroup group, SetEntry setToDelete) {
     if (mounted) {
       setState(() {
         setToDelete.repsController.dispose();
         setToDelete.weightController.dispose();
         group.sets.remove(setToDelete);
         if (group.sets.isEmpty) {
            _workoutGroups.remove(group);
         }
       });
     }
  }
  void _deleteWorkoutGroup(WorkoutGroup groupToDelete) {
     if (mounted) {
       setState(() {
         for (var set in groupToDelete.sets) {
           set.repsController.dispose();
           set.weightController.dispose();
         }
         _workoutGroups.remove(groupToDelete);
       });
     }
  }
  void _replaceExercise(WorkoutGroup groupToReplace) async {
     final newSelectedExercise = await Navigator.push<ExerciseModel>(
       context,
       MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
     );

     if (newSelectedExercise != null && mounted) {
       bool newExerciseExists = _workoutGroups.any((group) => group.exercise.id == newSelectedExercise.id && group != groupToReplace);
        if (newExerciseExists) {
           showInfoPopup(
            context,
            'Exercise Exists', 
            '${newSelectedExercise.name} is already in this workout session.' 
            );
           return;
        }
       setState(() {
          List<SetEntry> oldSets = List.from(groupToReplace.sets);
          final newGroup = WorkoutGroup(exercise: newSelectedExercise);
          newGroup.sets.clear();
          newGroup.sets.addAll(oldSets);

          int oldIndex = _workoutGroups.indexOf(groupToReplace);
          _workoutGroups.removeAt(oldIndex);
          _workoutGroups.insert(oldIndex, newGroup);
       });
     }
  }
  void _finishWorkout() { 
     bool allSetsCompleted = true;
     bool allValid = true;
     List<Map<String, dynamic>> sessionData = [];

      for (var group in _workoutGroups) {
       for (int i = 0; i < group.sets.length; i++) {
          final setEntry = group.sets[i];
          if (!setEntry.isCompleted) {
             allSetsCompleted = false;
             break;
          }
          final reps = int.tryParse(setEntry.repsController.text);
          final weightText = setEntry.weightController.text.trim().replaceAll(',', '.');
          final weight = double.tryParse(weightText);

          if (setEntry.repsController.text.trim().isEmpty || weightText.isEmpty || reps == null || weight == null) {
              allValid = false;
              showErrorPopup(
                context,
                'Invalid Input', 
                'Please enter valid Reps and Weight for: ${group.exercise.name} (Set ${i + 1})' 
              );
               break;
          }
           sessionData.add({
             'exerciseId': group.exercise.id,
             'exerciseName': group.exercise.name,
             'setNumber': i + 1,
             'reps': reps,
             'weight': weight,
             'isCompleted': setEntry.isCompleted,
           });
       }
       if (!allSetsCompleted || !allValid) break;
     }
     if (!allSetsCompleted) {
       showErrorPopup(
        context,
        'Sets Not Completed', 
        'Please check off all completed sets before saving the session.' 
      );
       return;
     }
      if (!allValid || sessionData.isEmpty) {
        if (sessionData.isEmpty && allValid && allSetsCompleted) { 
           showInfoPopup(
            context,
            'Empty Workout', 
            'Please add at least one exercise set before saving.' 
          );
        }
       return; 
     }
    print("[TrackingScreen] Finishing workout, navigating to Summary...");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          setsData: sessionData,
          duration: _duration,
          sessionStartTime: _sessionStartTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    for (var group in _workoutGroups) {
      for (var set in group.sets) {
        set.repsController.dispose();
        set.weightController.dispose();
      }
    }
    _minutesController.dispose(); 
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkoutViewModel>();
     if (!_isInitialized) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
     }

    final String timerText = _isResting
        ? _formatDuration(_currentRestTime) 
        : _formatDuration(_duration); 

    final Color timerColor = _isResting
        ? AppColors.success 
        : AppColors.textSecondary; 

    return PopScope(
      canPop: _workoutGroups.isEmpty, 
      onPopInvoked: (bool didPop) {
        if (didPop) return; 
        
        print("[PopScope] Pop blocked, showing discard dialog...");
        showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                title: const Text('Discard Workout?', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.onPrimary),),
                content: const Text('Are you sure you want to discard this workout session? All progress will be lost.', style: TextStyle(color: AppColors.onPrimary),),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                foregroundColor: AppColors.onPrimary,        
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                    ),
                        child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false); 
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(true); 
                  },
                  child: const Text('Yes, Discard'),
                ),
              ],
            );
          },
        ).then((bool? shouldDiscard) {
            if (shouldDiscard == true) {
              Navigator.of(context).pop(); 
            }
        });
      },
   
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true, 
          title: InkWell(
            onTap: _showEditRestTimerDialog, 
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: timerColor,
                ),
                const SizedBox(width: 8),
                Text(
                  timerText,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()], 
                  ),
                ),
              ],
            ),
          ),
          actions: [
             const SizedBox(width: 56), 
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: _workoutGroups.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Press the "Start Workout" button down below to start',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                           ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _workoutGroups.length,
                        itemBuilder: (context, index) {
                          final group = _workoutGroups[index];
                          return WorkoutGroupTile(
                            key: ValueKey(group.exercise.id),
                            group: group,
                            onAddSet: () => _addSetToGroup(group),
                            onDeleteSet: (setToDelete) => _deleteSetFromGroup(group, setToDelete),
                            onReplaceExercise: () => _replaceExercise(group),
                            onDeleteWorkout: () => _deleteWorkoutGroup(group),
                            onToggleSetComplete: (setEntry, isCompleted) {
                                if (mounted) {
                                  setState(() {
                                    setEntry.isCompleted = isCompleted;
                                  });
                                  if (isCompleted) {
                                    _startRestTimer();
                                  }
                                }
                            },  
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: OutlinedButton.icon(
                  onPressed: _navigateAndAddExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add exercise'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32), 
                    ),
                  ),
                ),
              ),
              if (_workoutGroups.isNotEmpty)
                SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: ElevatedButton(
                    onPressed: viewModel.state == ViewState.Loading ? null : _finishWorkout,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: viewModel.state == ViewState.Loading
                      ? const CircularProgressIndicator(color: Colors.white,)
                      : const Text('Finish & Save Session'),
                  ),
                ),
                SizedBox(height: 32,)
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutGroupTile extends StatelessWidget {
  final WorkoutGroup group;
  final VoidCallback onAddSet;
  final ValueChanged<SetEntry> onDeleteSet;
  final VoidCallback onReplaceExercise;
  final VoidCallback onDeleteWorkout;
  final Function(SetEntry, bool) onToggleSetComplete;

  const WorkoutGroupTile({
    super.key,
    required this.group,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onReplaceExercise,
    required this.onDeleteWorkout,
    required this.onToggleSetComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailScreen(exercise: group.exercise),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          group.exercise.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                 PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'replace':
                          onReplaceExercise();
                          break;
                        case 'delete_all':
                          onDeleteWorkout();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'replace',
                        child: ListTile(
                          leading: Icon(Icons.repeat, size: 20),
                          title: Text('Replace Exercise'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_all',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                          title: Text('Delete all set'),
                          dense: true,
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.onPrimary,),
                    
                    tooltip: 'Exercise option',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  )
              ],
            ),
            const Divider(height: 28, color: AppColors.divider,),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.sets.length,
              itemBuilder: (context, index) {
                final setEntry = group.sets[index];
                return SetRow(
                  key: ValueKey(setEntry.id),
                  setEntry: setEntry,
                  setNumber: index + 1,
                  onToggleComplete: (isCompleted) => onToggleSetComplete(setEntry, isCompleted),
                  onDelete: () => onDeleteSet(setEntry),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add, size: 18, color: AppColors.onError,),
                label: const Text('Add Set'),
                style: TextButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 8),
                   foregroundColor: AppColors.onPrimary,
                   backgroundColor: AppColors.secondary,
                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                   alignment: Alignment.center,
                   textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class SetRow extends StatelessWidget {
  final SetEntry setEntry;
  final int setNumber;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onDelete;

  const SetRow({
    super.key,
    required this.setEntry,
    required this.setNumber,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        color: Colors.redAccent.withOpacity(0.1),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20,),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30, height: 30, alignment: Alignment.center,
            child: Text(setNumber.toString(), style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: setEntry.weightController.text == '0.0' ? (TextEditingController()..text = '') : setEntry.weightController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(labelText: 'Weight (kg)', isDense: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[ FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.\,]?\d*')), ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: setEntry.repsController,
              style: const TextStyle( 
                color: Colors.white,
              ),
              decoration: const InputDecoration(labelText: 'Reps', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[ FilteringTextInputFormatter.digitsOnly ],
            ),
          ),
          const SizedBox(width: 8),
          Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                shape: const CircleBorder(), 
                side: const BorderSide(color: Colors.white, width: 2),
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.selected)) return AppColors.success; 
                    return Colors.transparent; 
                  },
                ),
                checkColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.disabled)) return Colors.grey;
                    if (states.contains(WidgetState.selected)) return Colors.white;
                    return Colors.white; 
                  },
                ), 
              ),
            ),
            child: Checkbox(
              value: setEntry.isCompleted,
              onChanged: (value) => onToggleComplete(value ?? false),
              visualDensity: VisualDensity.compact,
            ),
          )
        ],
      ),
    );
  }
}

