import 'package:medicinal_plant/forget_password.dart';
import 'package:medicinal_plant/utils/global_functions.dart';
import 'package:medicinal_plant/widget_tree.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'firebase_user_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  String? errorMessage = '';
  bool isLogin = true;
  bool isLoading = false;
  String successMessage = '';

  final TextEditingController _controllerEmailLogin = TextEditingController();
  final TextEditingController _controllerpasswordLogin =
      TextEditingController();
  final TextEditingController _controllerEmailSignup = TextEditingController();
  final TextEditingController _controllerpasswordSignup =
      TextEditingController();
  final TextEditingController _controllernameSignup = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 10.0), // Slide in from the right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    String error;
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmailLogin.text,
        password: _controllerpasswordLogin.text,
      );

      // Listen for auth state changes to confirm login
      Auth().authStateChanges.listen((User? user) {
        if (user != null) {
          setState(() {
            print("${user.email}.user Login successful");
            successMessage = 'Login Successful';
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetTree(),
            ),
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          error = 'This account has been disabled. Please contact support.';
          break;
        case 'wrong-password':
          error = 'Incorrect password. Please try again.';
          break;
        case 'user-not-found':
          error = 'No account exists with the entered email address.';
          break;
        case 'network-request-failed':
          error = 'Network error. Please check your internet connection.';
          break;
        case 'invalid-credential':
        case 'user-mismatch':
          error = 'An error occurred during sign in. Please try again later.';
          break;
        default:
          error = 'An unknown error occurred.';
      }
      setState(() {
        errorMessage = error;
      });
      print(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signUpWithUserEmailAndPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });
    String error;
    try {
      await Auth().signUpWithEmailandPassword(
          email: _controllerEmailSignup.text,
          password: _controllerpasswordSignup.text);
      setState(() {
        successMessage = 'Registration Successful';
      });
      isLogin = true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          error = 'This account has been disabled. Please contact support.';
          break;
        case 'wrong-password':
          error = 'Incorrect password. Please try again.';
          break;
        case 'user-not-found':
          error = 'No account exists with the entered email address.';
          break;
        case 'email-already-in-use':
          error = 'An account already exists with this email.';
          break;
        case 'operation-not-allowed':
          error = 'An error occurred. Please try again later.';
          break;
        case 'weak-password': // Handle weak password before Firebase call
          error = 'Password is not strong enough.';
          break;
        case 'network-request-failed':
          error = 'Network error. Please check your internet connection.';
          break;
        case 'invalid-credential':
        case 'user-mismatch':
          error = 'An error occurred during sign in. Please try again later.';
          break;
        default:
          error = 'An unknown error occurred.';
      }
      setState(() {
        errorMessage = error;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    storeUserDetails(_controllernameSignup.text, _controllerEmailSignup.text,
        _controllerpasswordSignup.text);
  }

  Widget entryField(
  Future<String> titleFuture,
  Future<String> hintFuture,
  TextEditingController controller,
  IconData iconType,
  bool isPass,
  bool obscureControl,
  Function(bool)? toggleObscureText
) {
  return SizedBox(
    height: 40,
    width: 250,
    child: Builder(
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: Future.wait([titleFuture, hintFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: TranslatedText('Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              final title = snapshot.data![0];
              final hint = snapshot.data![1];

              return TextField(
                obscureText: isPass,
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 2.0),
                  labelText: title,
                  labelStyle: const TextStyle(fontSize: 14),
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  floatingLabelStyle: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(
                    iconType,
                    size: 20,
                  ),
                  suffixIcon: obscureControl
                      ? IconButton(
                          icon: Icon(
                            isPass ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (toggleObscureText != null) {
                                toggleObscureText(!isPass);
                              }
                            });
                          },
                        )
                      : null,
                ),
              );
            } else {
              return const Center(child: TranslatedText('No data available'));
            }
          },
        );
      },
    ),
  );
}

  // ignore: unused_element
  Widget _errorMessage() {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox
          .shrink(); // Returns an empty widget if there's no error
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TranslatedText(
          '$errorMessage',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }
  }

  // Widget _googleAuthButton() {
  //   return SizedBox(
  //     height: 45,
  //     width: 300,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         Auth().loginWithGoogle();
  //       },
  //       style: ElevatedButton.styleFrom(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  //         foregroundColor: Colors.black,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Image.asset(
  //             'assets/icons/google.png',
  //             height: 20,
  //             width: 40,
  //           ),
  //           Text(
  //             isLogin ? 'Sign in with Google' : 'Sign up with Google',
  //             style: const TextStyle(
  //               color: Colors.black,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _googleAuthButton() {
    return SizedBox(
      height: 40,
      width: 250,
      child: SignInButton(
        Buttons.google,
        text: 'Sign up with Google',
        onPressed: () async {
          await Auth().loginWithGoogle(); // Await the loginWithGoogle() method
          // Handle successful login (e.g., navigate to home screen)
        },
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      height: 35,
      width: 250,
      child: ElevatedButton(
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : signUpWithUserEmailAndPassword,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 255, 42),
          foregroundColor: Colors.white,
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : TranslatedText(
                isLogin ? 'LOGIN' : 'REGISTER',
                style: const TextStyle(fontSize: 14),
              ),
      ),
    );
  }

  void toggleObscureText(bool newValue) {
    setState(() {
      ispass = newValue;
    });
  }

  var isChecked = true;
  var _textColor = Colors.blue;
  bool ispass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 196, 255, 255)),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 370,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/app_background.jpg"),
                        fit: BoxFit.cover)),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WidgetTree()),
                  );
                },
                iconSize: 20,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 3,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      color: const Color.fromARGB(255, 241, 255, 254),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 30,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(70),
                                  topRight: Radius.circular(70),
                                ),
                              ),
                              padding: const EdgeInsets.only(
                                  top: 50, bottom: 8, left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  TranslatedText(
                                    isLogin ? 'Login Page' : 'Register Page',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!isLogin) ...[
                                        entryField(
                                            translate('Name'),
                                            translate('Enter your name'),
                                            _controllernameSignup,
                                            Icons.person,
                                            false,
                                            false,
                                            toggleObscureText),
                                        const SizedBox(height: 16),
                                        entryField(
                                            translate('Email'),
                                            translate('Enter your email'),
                                            _controllerEmailSignup,
                                            Icons.email,
                                            false,
                                            false,
                                            toggleObscureText),
                                        const SizedBox(height: 16),
                                        entryField(
                                            translate('Password'),
                                            translate('Enter your password'),
                                            _controllerpasswordSignup,
                                            Icons.lock,
                                            ispass,
                                            true,
                                            toggleObscureText),
                                      ] else ...[
                                        const SizedBox(height: 16),
                                        entryField(
                                            translate('Email'),
                                            translate('Enter your email'),
                                            _controllerEmailLogin,
                                            Icons.email,
                                            false,
                                            false,
                                            toggleObscureText),
                                        const SizedBox(height: 16),
                                        entryField(
                                            translate('Password'),
                                            translate('Enter your password'),
                                            _controllerpasswordLogin,
                                            Icons.lock,
                                            ispass,
                                            true,
                                            toggleObscureText),
                                      ],

                                      // _errorMessage(),
                                      const SizedBox(height: 23),
                                      _submitButton(),
                                      if (errorMessage!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            errorMessage!,
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      if (successMessage.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            successMessage,
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 33,
                                      ),
                                      if (isLogin) ...[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () => {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Forget()))
                                              },
                                              child: Text(
                                                'Forget password',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.blue,
                                                  color: _textColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          TranslatedText(
                                            isLogin
                                                ? "Don't have an account? "
                                                : 'Already have an account? ',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          GestureDetector(
                                            onTap: () => setState(() {
                                              isLogin = !isLogin;
                                              _textColor = Colors.lightBlue;
                                            }),
                                            child: TranslatedText(
                                              isLogin ? 'register' : 'login',
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.blue,
                                                color: _textColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 23),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                                  color: Colors.grey,
                                                  height: 1)),
                                          const TranslatedText(
                                            ' Continue with ',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Expanded(
                                              child: Container(
                                                  color: Colors.grey,
                                                  height: 1)),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      _googleAuthButton()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
