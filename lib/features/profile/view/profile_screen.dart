import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 
import '../../auth/viewmodel/auth_viewmodel.dart'; 
import '../../history/viewmodel/history_viewmodel.dart';
import '../../streak/viewmodel/streak_viewmodel.dart';
import '../../../core/constants/app_colors.dart'; 

class ProfileScreen extends StatefulWidget {
 const ProfileScreen({super.key});

 @override
 State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

 @override
 void initState() {
   super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {
     context.read<StreakViewModel>().fetchAllStreakData();
     context.read<HistoryViewModel>().fetchHistory();
   });
 }

 String getInitials(String email) {
    if (email.isEmpty) return 'G';
    return email[0].toUpperCase();
 }

 @override
 Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authViewModel = context.read<AuthViewModel>(); 
    final streakViewModel = context.watch<StreakViewModel>(); 
    final historyViewModel = context.watch<HistoryViewModel>(); 

    final userEmail = user?.email ?? 'Guest';
    final userInitials = getInitials(userEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), 
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                 context: context,
                 builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                   title: const Text('Logout', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800 ),),
                   content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.onPrimary,)),
                   actions: [
                     TextButton(
                       child: const Text('Cancel'),
                       onPressed: () => Navigator.of(dialogContext).pop(),
                     ),
                      TextButton(
                        style: 
                          TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary, 
                          ),
                       child: const Text('Logout', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                       onPressed: () async { 
                          Navigator.of(dialogContext).pop();
                          try {
                            await authViewModel.signOut();
                            
                            print("[ProfileScreen] Logout successful, waiting for AuthWrapper...");

                          } catch (e) {
                            print("[ProfileScreen] Logout failed: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Logout gagal: ${e.toString().replaceFirst('Exception: ', '')}"),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                       },
                     ),
                   ],
                 ),
              );
            },
          ),
        ],
        // ---------------------------------------------
      ),
      body: RefreshIndicator( 
         onRefresh: () async {
            await context.read<StreakViewModel>().fetchAllStreakData();
            await context.read<HistoryViewModel>().fetchHistory();
         },
         child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar( 
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      userInitials,
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                 color: AppColors.onPrimary,
                 fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2, 
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              mainAxisSpacing: 12.0, 
              crossAxisSpacing: 12.0, 
              childAspectRatio: 1.2, 
              children: [
                _StatCard(
                   icon: Icons.local_fire_department_rounded,
                   iconColor: const Color.fromARGB(255, 255, 102, 64) ,
                   label: 'Current Streak',
                   value: streakViewModel.state == StreakState.Loading
                      ? '...'
                      : '${streakViewModel.currentStreak} Days',
                ),
                _StatCard(
                   icon: Icons.star_rounded,
                   iconColor: Colors.amber,
                   label: 'Highest Streak',
                   value: streakViewModel.state == StreakState.Loading
                      ? '...'
                      : '${streakViewModel.longestStreak} Days',
                ),
                _StatCard(
                   icon: Icons.fitness_center_rounded,
                   iconColor: Colors.blueAccent,
                   label: 'Total Workouts',
                   value: historyViewModel.state == HistoryState.Loading
                      ? '...'
                      : '${historyViewModel.sessions.length} Sessions',
                ),
                 _StatCard(
                   icon: Icons.monitor_weight_rounded,
                   iconColor: Colors.greenAccent,
                   label: 'Total Volume',
                   value: 'Soon', 
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, size: 30, color: iconColor),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                 fontWeight: FontWeight.bold,
                 color: AppColors.onPrimary, 
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: AppColors.textSecondary, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
