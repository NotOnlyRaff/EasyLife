import 'package:easy_life_application/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:easy_life_application/features/auth/view/widgets/custom_field.dart';
import 'package:easy_life_application/features/auth/view/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
    formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomText(
                  text: 'Easy Life',
                ),
                const SizedBox(height: 50),
                SearchBar( 
                      leading: const Icon(Icons.search),
                      hintText: 'Enter email',
                    ),
                const SizedBox(height: 30),
                AuthGradientButton(
                  buttonText: 'Report',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  buttonText: 'Account List',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
