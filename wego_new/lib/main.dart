import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wego_marriage/providers/story_provider.dart';
import 'package:wego_marriage/providers/user_provider.dart';
import 'package:wego_marriage/providers/settings_provider.dart';
import 'package:wego_marriage/providers/chat_provider.dart';
import 'package:wego_marriage/screen/splash_screen.dart';
import 'package:wego_marriage/screen/incoming_call_screen.dart';
import 'package:wego_marriage/services/local_storage_service.dart';

// ── Global navigator key (incoming call ke liye zaruri) ──
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalStorageService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Firestore incoming call listener
  Stream<QuerySnapshot>? _callStream;

  @override
  void initState() {
    super.initState();
    _startCallListener();
  }

  void _startCallListener() {
    // Auth state change pe listener lagao
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) return;

      // Jab bhi 'ringing' status aaye aur receiverId == currentUser
      _callStream = FirebaseFirestore.instance
          .collection('calls')
          .where('receiverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'ringing')
          .snapshots();

      _callStream!.listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() as Map<String, dynamic>;
            final callId = change.doc.id;
            final callerId = data['callerId'] as String? ?? '';
            final callType = data['type'] as String? ?? 'voice';

            // Caller info Firestore se fetch karo
            _fetchCallerAndShowScreen(
              callId: callId,
              callerId: callerId,
              callType: callType,
            );
          }
        }
      });
    });
  }

  Future<void> _fetchCallerAndShowScreen({
    required String callId,
    required String callerId,
    required String callType,
  }) async {
    try {
      // Call abhi bhi ringing hai? (double check)
      final callDoc = await FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .get();

      if (!callDoc.exists) return;
      final status = callDoc.data()?['status'] as String?;
      if (status != 'ringing') return;

      // Caller ki info fetch karo
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(callerId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final callerName = userData['name'] as String? ??
          userData['displayName'] as String? ??
          'Unknown';
      final callerImage = userData['photoUrl'] as String? ??
          userData['profileImage'] as String? ??
          '';

      // IncomingCallScreen dikhao
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(
            callId: callId,
            callerId: callerId,
            callerName: callerName,
            callerImage: callerImage,
            callType: callType,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error fetching caller info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'WeGo Marriage',
          debugShowCheckedModeBanner: false,

          // ✅ Global navigator key — incoming call ke liye
          navigatorKey: navigatorKey,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF4A6CF7),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode:
          settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}