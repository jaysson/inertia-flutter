import 'package:flutter/material.dart';
import 'package:inertia_flutter/inertia_flutter.dart';
import 'package:inertia_flutter_example/constants.dart';

class LoginFormData {
  String email;
  String password;

  LoginFormData({
    required this.email,
    required this.password,
  });

  LoginFormData copyWith({
    String? email,
    String? password,
  }) {
    return new LoginFormData(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, String> toMap() {
    return {
      'email': this.email,
      'password': this.password,
    };
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late InertiaForm<LoginFormData> _form;

  @override
  void initState() {
    _form = InertiaForm(LoginFormData(email: '', password: ''));
    super.initState();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SafeArea(
        child: StreamBuilder<InertiaFormState<LoginFormData>>(
            stream: _form.stateStream,
            builder: (context, snapshot) {
              final formState = snapshot.data;
              if (formState == null) {
                return Container();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(SPACING_UNIT * 4),
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: "Email"),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => _form.setValues(
                            formState.values.copyWith(email: value),
                          ),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                          onChanged: (value) => _form.setValues(
                            formState.values.copyWith(password: value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(SPACING_UNIT * 4),
                    child: ElevatedButton(
                      onPressed: formState.isSubmitting ? null : _submit,
                      child: Text("Login"),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  _submit() async {
    try {
      await _form.submit(
        path: 'login',
        method: 'post',
        transform: (data) => data.toMap(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 3),
      ));
    }
  }
}
