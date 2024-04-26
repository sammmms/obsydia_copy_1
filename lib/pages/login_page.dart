import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/pages/home_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final username = TextEditingController(text: "agus");
  final password = TextEditingController(text: "123456");
  late AuthBloc authBloc;
  late TenantBloc tenantBloc;
  @override
  void initState() {
    authBloc = context.read<AuthBloc>();
    tenantBloc = context.read<TenantBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Obsidia Fake Replica"),
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder(
                stream: authBloc.controller.stream,
                builder: (context, snapshot) {
                  bool state = snapshot.data?.loading ?? false;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/Obsidian.png",
                        width: 200,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        controller: username,
                        decoration:
                            const InputDecoration(labelText: "USERNAME"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: password,
                        decoration:
                            const InputDecoration(labelText: "PASSWORD"),
                      ),
                      const SizedBox(
                        height: 80,
                      ),

                      // Login button
                      SizedBox(
                        width: 200,
                        child: OutlinedButton(
                            onPressed: state
                                ? null
                                : () => handleLogin(context,
                                    routeTo: const HomePage()),
                            child: state
                                ? const LinearProgressIndicator()
                                : const Text("Login")),
                      )
                    ],
                  );
                }),
          ),
        ));
  }

  /// Try login to server, and push to specified route if success
  /// Otherwise, show a snack bar
  ///
  /// @routeTo : Widget to push when success
  handleLogin(context, {required Widget routeTo}) async {
    try {
      await authBloc.login(
          name: username.text, password: password.text, tenantBloc: tenantBloc);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => routeTo),
          (route) => false,
        );
      }
    } catch (err) {
      if (context.mounted) {
        showSnackBarComponent(context, err.toString());
      }
    }
  }
}
