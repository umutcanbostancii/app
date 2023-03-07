import 'dart:async';

import 'package:flutter/material.dart';

class IHome extends StatefulWidget {
  const IHome({super.key});

  @override
  State<IHome> createState() => _IHomeState();
}

class _IHomeState extends State<IHome> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  Timer? timer;
  Duration duration = Duration.zero;
  List<String> laps = [];
  int total = 0;

  bool get isStop => timer == null;
  bool get isActive => (timer != null && timer!.isActive);

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  add() {
    Duration dur = Duration(milliseconds: (isActive ? total : 0) + timer!.tick);
    laps.add(format(dur));
    setState(() {});
  }

  start() {
    if (isStop || !isActive) {
      controller.forward();
      timer = Timer.periodic(const Duration(milliseconds: 1), (_timer) {
        duration = Duration(milliseconds: total + _timer.tick);
        setState(() {
          format(duration);
        });
      });
    } else {
      controller.reverse();
      pause();
    }
  }

  pause() {
    if (!isStop) {
      total += timer!.tick;
      timer!.cancel();
    }
  }

  stop() {
    if (!isStop) {
      laps.clear();
      timer!.cancel();
      timer = null;
      total = 0;
      duration = Duration.zero;
      setState(() {});
      controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
        backgroundColor: const Color.fromRGBO(249, 249, 249, 1),
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Text(
                format(duration),
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isStop)
                    IconButton(
                        onPressed: () {
                          stop();
                        },
                        icon: const Icon(Icons.stop_outlined)),
                  IconButton(
                      onPressed: () {
                        start();
                      },
                      icon: AnimatedIcon(
                          icon: AnimatedIcons.play_pause, progress: animation)),
                  if (!isStop)
                    IconButton(
                        onPressed: () {
                          add();
                        },
                        icon: const Icon(Icons.flag_outlined)),
                ],
              ),
            ),
            if (!laps.isEmpty)
              Container(
                height: size.height * 0.4,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                    border: Border.all(width: 5),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      direction: Axis.vertical,
                      children: laps
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, right: 10, bottom: 5),
                                child: Text(
                                  e.toString(),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ))
                          .toList(),
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
