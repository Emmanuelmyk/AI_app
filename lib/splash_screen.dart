import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay for 3 seconds before navigating to the home page
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use theme background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/gym_pics.png',
              width: 300,
              color: Theme.of(context).primaryColor,
            ),

            const SizedBox(height: 3), // Space between icon and text
            Text(
              'AI Fitness App',
              style: TextStyle(
                fontSize: 32, // Text size
                fontWeight: FontWeight.bold, // Text weight
                color: Theme.of(context).primaryColor, // Text color from theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor:
          const Color.fromARGB(255, 175, 76, 76), // Set your primary color here
      scaffoldBackgroundColor: Colors.white, // Set your background color
    ),
    home: const SplashScreen(),
  ));
}
