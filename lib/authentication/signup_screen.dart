import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gobazar/authentication/login_screen.dart';
import 'package:gobazar/methods/common_methods.dart';
import 'package:gobazar/pages/home_page.dart';
import 'package:gobazar/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController userphoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final CommonMethods cMethods = CommonMethods();

  Future<void> checkIfNetworkIsAvailable() async {
    await cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  void signUpFormValidation() {
    if (usernameController.text.trim().length < 4) {
      cMethods.displaySnackBar("O nome do usuário deve conter pelo menos 4 caracteres", context);
    } else if (userphoneController.text.trim().length < 8) {
      cMethods.displaySnackBar("Informe um número de telefone válido", context);
    } else if (passwordController.text.trim().length < 7) {
      cMethods.displaySnackBar("A senha deve conter pelo menos 7 caracteres", context);
    } else if (!emailController.text.contains("@")) {
      cMethods.displaySnackBar("Email inválido", context);
    } else {
      registerNewUser();
    }
  }

  Future<void> registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registrando a conta..."),
    );

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(user.uid);

        Map<String, String> userDataMap = {
          "name": usernameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": userphoneController.text.trim(),
          "id": user.uid,
          "blockStatus": "no",
        };

        await userRef.set(userDataMap);

        if (!mounted) return;
        Navigator.pop(context); // Fecha o diálogo de carregamento após a criação da conta e do registro do usuário
        cMethods.displaySnackBar("Conta criada com sucesso!", context);

        // Redireciona para a HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => HomePage()),
        );
      } else {
        throw FirebaseAuthException(code: "unknown-error", message: "Usuário é nulo após criação.");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Fecha o diálogo de carregamento
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'A senha fornecida é muito fraca.';
          break;
        case 'email-already-in-use':
          errorMessage = 'A conta já existe para este email.';
          break;
        case 'invalid-email':
          errorMessage = 'O email fornecido é inválido.';
          break;
        default:
          errorMessage = 'Ocorreu um erro desconhecido: ${e.message}';
      }
      cMethods.displaySnackBar(errorMessage, context);
    } catch (e) {
      Navigator.pop(context); // Fecha o diálogo de carregamento
      cMethods.displaySnackBar('Ocorreu um erro. Tente novamente. Detalhes: $e', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const Text(
                "Crie uma Conta de Usuário",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Nome do Usuário",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userphoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Telefone",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 33),
                    ElevatedButton(
                      onPressed: checkIfNetworkIsAvailable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      ),
                      child: const Text("Registrar"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Já tem uma conta? Clique aqui",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
