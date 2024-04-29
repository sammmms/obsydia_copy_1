import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/home_page.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:obsydia_copy_1/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final authBloc = AuthBloc();
  final tenantBloc = TenantBloc();
  Tenant? response;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await authBloc.checkLogin();

        await tenantBloc.getTenant();
      } catch (err) {
        debugPrint(err.toString());
      }

      /// If check login has successfully done it's job, then remove the splash screen
      FlutterNativeSplash.remove();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBloc>.value(
          value: authBloc,
        ),
        Provider<TenantBloc>.value(
          value: tenantBloc,
        )
      ],
      child: Portal(
        child: MaterialApp(
          title: 'Obsidia Copycat',
          theme: themeData,
          home: StreamBuilder(
            stream: authBloc.controller.stream,
            builder: (context, snapshot) {
              if (snapshot.data?.auth != null) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}
