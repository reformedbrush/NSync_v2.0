import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';
import 'package:nsync_stud/screen/homepg.dart';
import 'package:nsync_stud/screen/register_now.dart';
import 'package:cherry_toast/cherry_toast.dart';

class Login1 extends StatefulWidget {
  const Login1({super.key});

  @override
  State<Login1> createState() => _Login1State();
}

class _Login1State extends State<Login1> {
  //controllers
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();

  Future<void> studLogin() async {
    try {
      final auth = await supabase.auth.signInWithPassword(
        password: _PasswordController.text,
        email: _loginController.text,
      );
      String uid = auth.user!.id;
      final res =
          await supabase
              .from("tbl_student")
              .select()
              .eq("student_id", uid)
              .maybeSingle();

      if (res != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentHome()),
        );
      } else {
        CherryToast.error(
          description: const Text(
            "Invalid User",
            style: TextStyle(color: Colors.black),
          ),
          animationType: AnimationType.fromRight,
          animationDuration: const Duration(milliseconds: 1000),
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      CherryToast.error(
        description: Text("$e", style: const TextStyle(color: Colors.black)),
        animationType: AnimationType.fromRight,
        animationDuration: const Duration(milliseconds: 1000),
        autoDismiss: true,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            SizedBox(
              height: 360,
              child: Image.asset("./assets/Brazuca Browsing.png"),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Container(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: TextFormField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    hintText: "Login",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: TextFormField(
                  controller: _PasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    suffixIcon: Icon(Icons.remove_red_eye),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF161616),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 150, vertical: 18),
              ),
              onPressed: () {
                studLogin();
              },
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("Forgot Password?"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Get new",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Do not have an account?"),
                TextButton(
                  child: Text(
                    "Register Now!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registernow()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
