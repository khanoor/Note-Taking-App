import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_test/todo_list.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, navigationPage);
  }

  void navigationPage() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TaskList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset("assets/Ecxd.gif"),
              ),
              const SizedBox(height: 10,),
            const Text("Note-Taking App", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), )
          ],
        ),
      ),
    );
  }
}
