import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'game.dart';
import 'main.dart';
import 'package:flutter/services.dart';

// import 'app.dart';
import 'tile_widget.dart';

class Flutter2048State extends State<Flutter2048>
    with TickerProviderStateMixin {
  final game = Game();

  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    game.initBoard();
  }

  @override
  void dispose() {
    _scoreController.close();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (game.moveUp()) {
            _updateGameState();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (game.moveDown()) {
            _updateGameState();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (game.moveLeft()) {
            _updateGameState();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (game.moveRight()) {
            _updateGameState();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        // if (kDebugMode) {
        //   print("IS GAME OVER ");
        // }
        setState(() {
          game.fillBoard();
          _updateGameState();
        });
      }
    }
    return KeyEventResult.handled;
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
              Text('Score: ${game.getScore()}'),
              Text('High Score: ${game.getHighScore()}'),
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

// This function updates the game state after each move, by checking if the game is over or not.
// If the game is over, it displays the "Game Over" dialog and updates the high score if needed.
// If the game is not over, it spawns a new tile on the board and checks again if the game is over.
// It updates the score in the UI and calls setState() to rebuild the widget tree.
  void _updateGameState() {
    if (kDebugMode) {
      print("UpdateGameState");
    }
    if (game.isGameOver()) {
      // Check if the game is over
      if (kDebugMode) {
        print("Game Over1");
      }
      if (game.getScore() > game.getHighScore()) {
        game.setHighScore(game.getScore());
      }
      _showGameOverDialog();
    } else {
      // If the game is not over, spawn a new tile and check again
      game.spawnNewTile();
      if (game.isGameOver()) {
        if (kDebugMode) {
          print("Game Over2");
        }

        if (game.getScore() > game.getHighScore()) {
          game.setHighScore(game.getScore());
        }
        _showGameOverDialog();
      }
    }

    // update the score in the UI
    _scoreController.add(game.getScore());
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
    // Get the value of the tile at the given x, y position
    int value = game.getBoardValue(x, y);

    // Get the last merged value of the tile at the given x, y position
    int? lastMergedValue = game.getLastMergedValueAt(x, y);

    // Set the text color of the tile based on its value
    Color? textColor = value < 8 ? Colors.grey[800] : Colors.white;

    // Get the background color of the tile based on its value
    Color? bgColor = _getTileColor(value);

    // If the tile was merged with another tile during the last move
    if (lastMergedValue != null) {
      // Scale the tile down when it is merged
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 0.9),
        duration: const Duration(milliseconds: 100),
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
                      // Display the last merged value of the tile
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
        // Reset the last merged value of the tile after the animation is completed
        onEnd: () {
          setState(() {
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
                // Display the value of the tile
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

// This widget builds the game grid.
  Widget _buildGrid() {
    return GridView.builder(
      // Defines the grid layout.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns in the grid.
        crossAxisSpacing: 10.0, // Spacing between the columns.
        mainAxisSpacing: 10.0, // Spacing between the rows.
        childAspectRatio: 1.0, // Aspect ratio of each grid item.
      ),
      // Builds the grid tiles.
      itemBuilder: (BuildContext context, int index) {
        // Calculates the x and y coordinates of the current index in the grid.
        int x = index % 4;
        int y = index ~/ 4;
        // Builds the tile for the current index.
        return _buildTile(x, y);
      },
      itemCount: 16, // Total number of tiles in the grid.
      physics:
          const NeverScrollableScrollPhysics(), // Disables scrolling in the grid.
      padding: EdgeInsets.zero, // No padding around the grid.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
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
                          stream: game.highScoreStream,
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
                        // _highScoreController.add(game.getHighScore());
                      },
                      child: Text('Restart Game'),
                    ),
                  ],
                ), // Row end
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 16.0), // Add padding below the grid

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
                            // _highScoreController.add(game.getHighScore());
                          });
                          _updateGameState();
                        }
                      },
                      onSwipeRight: (Offset offset) {
                        // Swipe right
                        if (game.moveRight()) {
                          setState(() {
                            _scoreController.add(game.getScore());
                            // _highScoreController.add(game.getHighScore());
                          });
                          _updateGameState();
                        }
                      },
                      onSwipeUp: (Offset offset) {
                        // Swipe up
                        if (game.moveUp()) {
                          setState(() {
                            _scoreController.add(game.getScore());
                            // _highScoreController.add(game.getHighScore());
                          });
                          _updateGameState();
                        }
                      },
                      onSwipeDown: (Offset offset) {
                        // Swipe down
                        if (game.moveDown()) {
                          setState(() {
                            _scoreController.add(game.getScore());
                            // _highScoreController.add(game.getHighScore());
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
      ),
    );
  }
}
