import 'package:flutter/material.dart';
import 'dart:math';
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
  List<List<int>> _board = List.generate(4, (_) => List.generate(4, (_) => 0));
  Map<String, int> _lastMergedValueAt = {};

  int _score = 0;
  int _highScore = 0;
  bool kDebugMode = true;

  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final StreamController<int> _highScoreController =
      StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  @override
  void dispose() {
    _scoreController.close();
    _highScoreController.close();
    super.dispose();
  }

  // This function initializes the game board as a 4x4 grid and spawns two new tiles.
  void _initBoard() {
    // Generate a 4x4 grid filled with zeros.
    _board = List.generate(4, (_) => List.generate(4, (_) => 0));

    // Spawn two new tiles randomly on the board.
    _spawnNewTile();
    _spawnNewTile();
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
              Text('Score: $_score'),
              Text('High Score: $_highScore'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                setState(() {
                  _initBoard();
                  _score = 0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // This function spawns a new tile with value 2 (90% probability) or 4 (10% probability) in an available cell.
  void _spawnNewTile() {
    // Create a list to store the indices of available cells (cells with value 0).
    List<int> availableCells = [];

    // Iterate through the board and find available cells.
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        // If the cell is available (value is 0), add its index to the list.
        if (_board[y][x] == 0) {
          availableCells.add(y * 4 + x);
        }
      }
    }

    // If there are any available cells,
    if (availableCells.isNotEmpty) {
      // Pick a random index from the list of available cells.
      int randomIndex = Random().nextInt(availableCells.length);
      int cellIndex = availableCells[randomIndex];

      // Calculate the row (y) and column (x) coordinates of the selected cell.
      int y = cellIndex ~/ 4;
      int x = cellIndex % 4;

      // Assign a value of 2 (90% probability) or 4 (10% probability) to the selected cell.
      _board[y][x] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool _moveLeft() {
    if (kDebugMode) {
      print("Move Left");
    }
    bool moved = false;

    // Iterate through each row
    for (int y = 0; y < 4; y++) {
      int lastMergedValue = 0;
      int lastMergedIndex = -1;

      // Iterate through each column starting from the second column (index 1)
      for (int x = 1; x < 4; x++) {
        int currentValue = _board[y][x];
        if (currentValue == 0) continue; // Skip empty cells

        int targetX = x;
        // Move the current tile to the left until an occupied cell or the edge of the grid is reached
        while (targetX > 0 && _board[y][targetX - 1] == 0) {
          targetX--;
        }

        // Check if the tile can be merged with the tile to its left
        if (targetX - 1 >= 0 &&
            _board[y][targetX - 1] == currentValue &&
            currentValue != lastMergedValue) {
          _board[y][targetX - 1] = currentValue * 2; // Merge the tiles
          _board[y][x] = 0;
          lastMergedValue = currentValue;
          lastMergedIndex = targetX - 1;
          moved = true;
          _score += currentValue * 2;
          _lastMergedValueAt['$y,$lastMergedIndex'] = currentValue * 2;
        } else if (targetX != x) {
          // Check if the tile has moved but not merged
          _board[y][targetX] =
              currentValue; // Move the tile to the new position
          _board[y][x] = 0; // Set the original position to empty
          moved = true;
        }
      }
    }

    return moved;
  }

  bool _moveRight() {
    if (kDebugMode) {
      print("Move Right");
    }
    bool moved = false;

    for (int y = 0; y < 4; y++) {
      int lastMergedValue = 0;
      int lastMergedIndex = -1;

      for (int x = 2; x >= 0; x--) {
        int currentValue = _board[y][x];
        if (currentValue == 0) continue;

        int targetX = x;
        while (targetX < 3 && _board[y][targetX + 1] == 0) {
          targetX++;
        }

        if (targetX + 1 < 4 &&
            _board[y][targetX + 1] == currentValue &&
            currentValue != lastMergedValue) {
          _board[y][targetX + 1] = currentValue * 2;
          _board[y][x] = 0;
          lastMergedValue = currentValue;
          lastMergedIndex = targetX + 1;
          moved = true;
          _score += currentValue * 2;
          _lastMergedValueAt['$y,$lastMergedIndex'] = currentValue * 2;
        } else if (targetX != x) {
          _board[y][targetX] = currentValue;
          _board[y][x] = 0;
          moved = true;
        }
      }
    }

    return moved;
  }

  bool _moveUp() {
    if (kDebugMode) {
      print("Move Up");
    }
    bool moved = false;

    for (int x = 0; x < 4; x++) {
      int lastMergedValue = 0;
      int lastMergedIndex = -1;

      for (int y = 1; y < 4; y++) {
        int currentValue = _board[y][x];
        if (currentValue == 0) continue;

        int targetY = y;
        while (targetY > 0 && _board[targetY - 1][x] == 0) {
          targetY--;
        }

        if (targetY - 1 >= 0 &&
            _board[targetY - 1][x] == currentValue &&
            currentValue != lastMergedValue) {
          _board[targetY - 1][x] = currentValue * 2;
          _board[y][x] = 0;
          lastMergedValue = currentValue;
          lastMergedIndex = targetY - 1;
          moved = true;
          _score += currentValue * 2;
          // _lastMergedValueAt['$y,$lastMergedIndex'] = currentValue * 2;
          _lastMergedValueAt['$lastMergedIndex,$x'] = currentValue * 2;
        } else if (targetY != y) {
          _board[targetY][x] = currentValue;
          _board[y][x] = 0;
          moved = true;
        }
      }
    }

    return moved;
  }

  bool _moveDown() {
    if (kDebugMode) {
      print("Move Down");
    }
    bool moved = false;

    for (int x = 0; x < 4; x++) {
      int lastMergedValue = 0;
      int lastMergedIndex = -1;

      for (int y = 2; y >= 0; y--) {
        int currentValue = _board[y][x];
        if (currentValue == 0) continue;

        int targetY = y;
        while (targetY < 3 && _board[targetY + 1][x] == 0) {
          targetY++;
        }

        if (targetY + 1 < 4 &&
            _board[targetY + 1][x] == currentValue &&
            currentValue != lastMergedValue) {
          _board[targetY + 1][x] = currentValue * 2;
          _board[y][x] = 0;
          lastMergedValue = currentValue;
          lastMergedIndex = targetY + 1;
          moved = true;
          _score += currentValue * 2;
          // _lastMergedValueAt['$y,$lastMergedIndex'] = currentValue * 2;
          _lastMergedValueAt['${targetY + 1},$x'] = currentValue * 2;
        } else if (targetY != y) {
          _board[targetY][x] = currentValue;
          _board[y][x] = 0;
          moved = true;
        }
      }
    }

    return moved;
  }

  bool _isGameOver() {
    // Check if there are any empty cells
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (_board[y][x] == 0) {
          return false;
        }
      }
    }

    // Check if there are any adjacent cells with the same value
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        int currentValue = _board[y][x];
        if (y > 0 && _board[y - 1][x] == currentValue) return false;
        if (y < 3 && _board[y + 1][x] == currentValue) return false;
        if (x > 0 && _board[y][x - 1] == currentValue) return false;
        if (x < 3 && _board[y][x + 1] == currentValue) return false;
      }
    }

    return true;
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(4, (_) => List.filled(4, 0));
      _score = 0;
      _scoreController.add(_score);
      _spawnNewTile();
      _spawnNewTile();
    });
  }

  void _updateGameState() {
    setState(() {
      _spawnNewTile();
      if (_isGameOver()) {
        // _highScore = max(_highScore, _score);
        // Display game over message or perform other actions
        _showGameOverDialog();
      }
      _highScore = max(_highScore, _score);
      _scoreController.add(_score);
      _highScoreController.add(_highScore);
    });
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
    int value = _board[y][x];
    Color? textColor = value < 8 ? Colors.grey[800] : Colors.white;
    Color? bgColor = _getTileColor(value);

    if (_lastMergedValueAt['$y,$x'] != null) {
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
                      '${_lastMergedValueAt['$y,$x']}',
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
            _lastMergedValueAt.remove('$y,$x');
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
                        initialData: _score,
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
                        initialData: _highScore,
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          return Text('${snapshot.data}');
                        },
                      ),
                    ],
                  ), // Column for High Score end
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: Text('Restart'),
                  ),
                ],
              ), // Row end
            ),
            Expanded(
              child: AspectRatio(
                // AspectRatio start
                aspectRatio: 1.0,
                // child: GestureDetector(
                //   onVerticalDragEnd: (details) {
                //     if (details.primaryVelocity != null &&
                //         details.primaryVelocity! < -100) {
                //       // Swipe up
                //       if (_moveUp()) {
                //         _updateGameState();
                //       }
                //     } else if (details.primaryVelocity != null &&
                //         details.primaryVelocity! > 100) {
                //       // Swipe down
                //       if (_moveDown()) {
                //         _updateGameState();
                //       }
                //     }
                //   },
                //   onHorizontalDragEnd: (details) {
                //     if (details.primaryVelocity != null &&
                //         details.primaryVelocity! < -100) {
                //       // Swipe left
                //       if (_moveLeft()) {
                //         _updateGameState();
                //       }
                //     } else if (details.primaryVelocity != null &&
                //         details.primaryVelocity! > 100) {
                //       // Swipe right
                //       if (_moveRight()) {
                //         _updateGameState();
                //       }
                //     }
                //   },
                //   child: Container(
                //     padding: EdgeInsets.all(10.0),
                //     color: Colors.grey[800],
                //     child: _buildGrid(),
                //   ),
                // ),
                child: SwipeDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.grey[800],
                    child: _buildGrid(),
                  ),
                  onSwipeLeft: (Offset offset) {
                    // Added Offset parameter
                    // Swipe left
                    if (_moveLeft()) {
                      _updateGameState();
                    }
                  },
                  onSwipeRight: (Offset offset) {
                    // Added Offset parameter

                    // Swipe right
                    if (_moveRight()) {
                      _updateGameState();
                    }
                  },
                  onSwipeUp: (Offset offset) {
                    // Added Offset parameter
                    // Swipe up
                    if (_moveUp()) {
                      _updateGameState();
                    }
                  },
                  onSwipeDown: (Offset offset) {
                    // Added Offset parameter
                    // Swipe down
                    if (_moveDown()) {
                      _updateGameState();
                    }
                  },
                ),
              ), // AspectRatio end
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
