// import 'package:flutter/material.dart';
// import 'package:gobazar/authentication/signup_screen.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => LoginScreenState();
// }
//
// TextEditingController emailTextEditingController = TextEditingController();
// TextEditingController passwordTextEditingController = TextEditingController();
//
//
//
// class LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//
//               Image.asset(
//                   "assets/images/logo.png"
//               ),
//
//               const Text(
//                 "Login Usuario",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               //text fields
//               Padding(
//
//                 padding: const EdgeInsets.all(22),
//                 child: Column(
//                   children: [
//
//
//                     const SizedBox(height: 22,),
//
//                     TextField(
//                       controller: emailTextEditingController,
//                       keyboardType: TextInputType.text,
//                       decoration: const InputDecoration(
//                         labelText: "User email",
//                         labelStyle: TextStyle(
//                           fontSize: 14,
//                         ),
//                       ),
//
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15,
//                       ),
//                     ),
//
//                     const SizedBox(height: 22,),
//
//                     TextField(
//                       controller: passwordTextEditingController,
//                       obscureText: true,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: const InputDecoration(
//                         labelText: "User password",
//                         labelStyle: TextStyle(
//                           fontSize: 14,
//                         ),
//                       ),
//
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15,
//                       ),
//                     ),
//
//                     const SizedBox(height: 32,),
//
//                     ElevatedButton(
//                       onPressed: ()
//                       {
//
//                       },
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple,
//                           padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
//                       ),
//                       child: const Text(
//                           "Entrar"
//                       ),
//                     ),
//                   ],
//                 ),
//
//               ),
//               const SizedBox(height: 12,),
//               TextButton(
//                 onPressed: ()
//                 {
//                   Navigator.push(context, MaterialPageRoute(builder: (c)=>SignUpScreen()));
//                 },
//
//                 child: const Text(
//                   "Se nao tens conta click aqui",
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gobazar/pages/home_page.dart';
import 'package:gobazar/authentication/signup_screen.dart';
import 'package:gobazar/widgets/loading_dialog.dart';
import '../methods/common_methods.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable(BuildContext context) async {
    await cMethods.checkConnectivity(context);
    signInFormValidation(context);
  }

  signInFormValidation(BuildContext context) {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Email inválido", context);
    } else if (passwordTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar("A senha deve conter pelo menos 7 caracteres", context);
    } else {
      signInUser(context);
    }
  }

  signInUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "A entrar na sua conta..."),
    );

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(user.uid);
        userRef.once().then((DatabaseEvent event) {
          DataSnapshot snap = event.snapshot;
          if (snap.value != null) {
            if ((snap.value as Map)["blockStatus"] == "no") {
              String userName = (snap.value as Map)["name"];
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomePage()));
            } else {
              FirebaseAuth.instance.signOut();
              cMethods.displaySnackBar("A sua conta está bloqueada. Contacte o administrador.", context);
            }
          }
        });


      } else {
        FirebaseAuth.instance.signOut();
        cMethods.displaySnackBar("Conta não existe", context);
      }
    } catch (e) {
      print("Error: $e");
      cMethods.displaySnackBar("Ocorreu um erro. Por favor, tente novamente.", context);
    } finally {
      Navigator.pop(context);
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
                "Login Usuario",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const SizedBox(height: 22,),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "E-mail do usuário",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22,),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Senha do usuário",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32,),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text("Entrar"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
                child: const Text(
                  "Se não tem conta, clique aqui",
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

