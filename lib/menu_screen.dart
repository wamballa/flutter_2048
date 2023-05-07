import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter 2048'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Text('Start Game'),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: Text('Settings'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/about');
              },
              child: const Text('About'),
            ),
          ],
        ),
      ),
    );
  }
}
