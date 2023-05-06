import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// import 'dart:math';
import 'dart:async';
// import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'game.dart';
import 'package:audioplayers/audioplayers.dart';

// https://github.com/anuranBarman/2048

void main() {
  runApp(MaterialApp(
    home: Flutter2048(),
    debugShowCheckedModeBanner: false,
  ));
}

class Flutter2048 extends StatefulWidget {
  @override
  _Flutter2048State createState() => _Flutter2048State();
}

class _Flutter2048State extends State<Flutter2048>
    with TickerProviderStateMixin {
  // List<List<int>> _board = List.generate(4, (_) => List.generate(4, (_) => 0));
  // Map<String, int> _lastMergedValueAt = {};

  final game = Game();

  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final StreamController<int> _highScoreController =
      StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    game.initBoard();
  }

  @override
  void dispose() {
    _scoreController.close();
    _highScoreController.close();
    super.dispose();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Score: $game.getScore()'),
              Text('High Score: $game.getHighScore'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                setState(() {
                  game.initBoard();
                  game.setScore(0);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateGameState() {
    if (game.isGameOver()) {
      if (kDebugMode) {
        print("Game Over");
      }
      if (game.getScore() > game.getHighScore()) {
        game.setHighScore(game.getScore());
        _highScoreController.add(game.getHighScore());
      }
    } else {
      game.spawnNewTile();
    }

    // update the score in the UI
    _scoreController.add(game.getScore());
    _highScoreController.add(game.getHighScore());

    setState(() {});
  }

  Color? _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[300];
      case 4:
        return Colors.grey[400];
      case 8:
        return Colors.orange[300];
      case 16:
        return Colors.orange[400];
      case 32:
        return Colors.orange[500];
      case 64:
        return Colors.orange[600];
      case 128:
        return Colors.orange[700];
      case 256:
        return Colors.orange[800];
      case 512:
        return Colors.orange[900];
      case 1024:
        return Colors.yellow[600];
      case 2048:
        return Colors.yellow[700];
      default:
        return Colors.grey[200];
    }
  }

  Widget _buildTile(int x, int y) {
    int value = game.getBoardValue(x, y);
    int? lastMergedValue = game.getLastMergedValueAt(x, y);
    Color? textColor = value < 8 ? Colors.grey[800] : Colors.white;
    Color? bgColor = _getTileColor(value);

    // if (_lastMergedValueAt['$y,$x'] != null) {
    if (lastMergedValue != null) {
      // Scale the tile down when it is merged
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 0.9),
        duration: Duration(milliseconds: 100),
        builder: (BuildContext context, double scale, Widget? child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: bgColor,
              ),
              alignment: Alignment.center,
              child: value != 0
                  ? Text(
                      // '${_lastMergedValueAt['$y,$x']}',
                      '$lastMergedValue',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    )
                  : null,
            ),
          );
        },
        onEnd: () {
          // Reset the last merged value after the animation is completed
          setState(() {
            // _lastMergedValueAt.remove('$y,$x');
            game.resetLastMergedValueAt(x, y);
          });
        },
      );
    } else {
      // Normal tile
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: bgColor,
        ),
        alignment: Alignment.center,
        child: value != 0
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              )
            : null,
      );
    }
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        int x = index % 4;
        int y = index ~/ 4;
        return _buildTile(x, y);
      },
      itemCount: 16,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter 2048'),
      ),
      body: Center(
        child: Column(
          // Column start
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                // Row start
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    // Column for Score start
                    children: [
                      Text('Score'),
                      StreamBuilder<int>(
                        stream: _scoreController.stream,
                        initialData: game.getScore(),
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          return Text('${snapshot.data}');
                        },
                      ),
                    ],
                  ), // Column for Score end

                  Column(
                    // Column for High Score start
                    children: [
                      Text('High Score'),

                      // Text('$_highScore'),
                      StreamBuilder<int>(
                        stream: _highScoreController.stream,
                        initialData: game.getHighScore(),
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          return Text('${snapshot.data}');
                        },
                      ),
                    ],
                  ), // Column for High Score end
                  // ElevatedButton(
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        game.resetGame();
                      });
                      _scoreController.add(game.getScore());
                      _highScoreController.add(game.getHighScore());
                    },
                    child: Text('Restart Game'),
                  ),
                ],
              ), // Row end
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: 16.0), // Add padding below the grid

                child: AspectRatio(
                  // AspectRatio start
                  aspectRatio: 1.0,
                  child: SwipeDetector(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      color: Colors.grey[800],
                      child: _buildGrid(),
                    ),
                    onSwipeLeft: (Offset offset) {
                      // Added Offset parameter
                      // Swipe left
                      // if (_moveLeft()) {
                      if (game.moveLeft()) {
                        setState(() {
                          _scoreController.add(game.getScore());
                          _highScoreController.add(game.getHighScore());
                        });
                        _updateGameState();
                      }
                    },
                    onSwipeRight: (Offset offset) {
                      // Swipe right
                      if (game.moveRight()) {
                        setState(() {
                          _scoreController.add(game.getScore());
                          _highScoreController.add(game.getHighScore());
                        });
                        _updateGameState();
                      }
                    },
                    onSwipeUp: (Offset offset) {
                      // Swipe up
                      if (game.moveUp()) {
                        setState(() {
                          _scoreController.add(game.getScore());
                          _highScoreController.add(game.getHighScore());
                        });
                        _updateGameState();
                      }
                    },
                    onSwipeDown: (Offset offset) {
                      // Swipe down
                      if (game.moveDown()) {
                        setState(() {
                          _scoreController.add(game.getScore());
                          _highScoreController.add(game.getHighScore());
                        });
                        _updateGameState();
                      }
                    },
                  ),
                ), // AspectRatio end
              ),
            ),
          ],
        ), // Column end
      ),
    );
  }
}

enum SwipeDirection { up, down, left, right }

class Tile extends StatelessWidget {
  final int value;

  Tile({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          value != 0 ? '$value' : '',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
