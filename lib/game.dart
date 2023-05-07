import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Game {
  List<List<int>> _board = List.generate(4, (_) => List.generate(4, (_) => 0));
  Map<String, int> _lastMergedValueAt = {};

  int _score = 0;
  int _highScore = 0;

  StreamController<int> _highScoreController = StreamController<int>();

  Stream<int> get highScoreStream => _highScoreController.stream;

  void dispose() {
    _highScoreController.close();
  }

  Game() {
    _loadHighScore().then((loadedHighScore) {
      _highScore = loadedHighScore;
      // print("CONSTRUCTOR... HighScore = $_highScore");
      _highScoreController.add(_highScore); // Add this line
    });
    resetGame();
  }

  Future<void> _storeHighScore(int highScore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
  }

  Future<int> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  void fillBoard() {
    int i = 1;
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        _board[x][y] = i++;
      }
    }
  }

  void initBoard() {
    _board = List.generate(4, (_) => List.generate(4, (_) => 0));
    spawnNewTile();
    spawnNewTile();
  }

  int getBoardValue(int x, int y) {
    return _board[y][x];
  }

  int? getLastMergedValueAt(int x, int y) {
    return _lastMergedValueAt['$y,$x'];
  }

  void resetLastMergedValueAt(int x, int y) {
    _lastMergedValueAt.remove('$y,$x');
  }

  int getScore() {
    return _score;
  }

  void setScore(int v) {
    _score = v;
  }

  int getHighScore() {
    return _highScore;
  }

  void setHighScore(int v) {
    _highScore = v;
    _storeHighScore(v);
  }

  bool moveLeft() {
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

  bool moveRight() {
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

  bool moveUp() {
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

  bool moveDown() {
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

  void resetGame() async {
    if (kDebugMode) {
      print("Restart Game");
    }

    // int loadedHighScore = await _loadHighScore();
    // _highScore = loadedHighScore;

    if (_score > _highScore) {
      print("Reset HighScore  ");
      _highScore = _score;
      _storeHighScore(_highScore);
    }
    _board = List.generate(4, (_) => List.filled(4, 0));
    _score = 0;

    print("resetGame: Highscore = $_highScore");
    _highScoreController.add(_highScore);
    spawnNewTile();
    spawnNewTile();
  }

  void spawnNewTile() {
    // Find available cells to spawn a new tile
    List<int> availableCells = [];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (_board[y][x] == 0) {
          availableCells.add(y * 4 + x);
        }
      }
    }

    // Spawn a new tile if there is an available cell
    if (availableCells.isNotEmpty) {
      // Choose a random available cell to spawn a new tile
      int randomIndex = Random().nextInt(availableCells.length);
      int cellIndex = availableCells[randomIndex];
      int y = cellIndex ~/ 4;
      int x = cellIndex % 4;

      // The new tile has a 90% chance to be 2 and a 10% chance to be 4
      _board[y][x] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool isGameOver() {
    if (kDebugMode) {
      print("isGameOver: check");
    }
    print("Board = $_board");
    // Check if there are any empty cells
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (_board[y][x] == 0) {
          return false;
        }
      }
    }
    if (kDebugMode) {
      print("isGameOver: No Empty Cells");
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
}
