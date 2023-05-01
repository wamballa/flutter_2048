import 'dart:math';

class Game {
  List<List<int>> _board = List.generate(4, (_) => List.generate(4, (_) => 0));
  Map<String, int> _lastMergedValueAt = {};

  int _score = 0;

  void initBoard() {
    _board = List.generate(4, (_) => List.generate(4, (_) => 0));
    spawnNewTile();
    spawnNewTile();
  }

  bool moveLeft() {
    print('Move Left');
    // logic for moving tiles left
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
    // logic for moving tiles right
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
    // logic for moving tiles up
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
    // logic for moving tiles down
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

  // bool hasValidMoves() {
  //   // logic for checking if there are valid moves
  // }

  void resetGame() {
    _board = List.generate(4, (_) => List.filled(4, 0));
    _score = 0;
    spawnNewTile();
    spawnNewTile();
  }

  void spawnNewTile() {
    print('Spawn Tile');
    // logic for spawning a new tile
    List<int> availableCells = [];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (_board[y][x] == 0) {
          availableCells.add(y * 4 + x);
        }
      }
    }

    if (availableCells.isNotEmpty) {
      int randomIndex = Random().nextInt(availableCells.length);
      int cellIndex = availableCells[randomIndex];
      int y = cellIndex ~/ 4;
      int x = cellIndex % 4;
      _board[y][x] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool isGameOver() {
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

  // other functions and variables related to the game mechanics

  // getters and setters for private variables
}
