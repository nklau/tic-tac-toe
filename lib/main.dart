import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatefulWidget {
  const TicTacToeApp({super.key});

  @override
  State<TicTacToeApp> createState() => _TicTacToeApp();
}

class _TicTacToeApp extends State<TicTacToeApp> {
  int _oScore = 0, _xScore = 0;

  void _incrementScore(String playerSymbol) {
    setState(() {
      if (playerSymbol == 'O') {
        _oScore += 1;
      } else if (playerSymbol == 'X') {
        _xScore += 1;
      } else {
        throw ArgumentError('Unknown player symbol $playerSymbol.');
      }
    });
  }

  void _resetScores() {
    setState(() {
      _oScore = 0;
      _xScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Tic Tac Toe')),
        body: Column(
          children: [
            PlayerInfo(oScore: _oScore, xScore: _xScore),
            TicTacToeGame(onWin: _incrementScore),
            ElevatedButton(
              onPressed: () {
                _resetScores();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              child: const Text('Reset Scores'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerInfo extends StatelessWidget {
  final int oScore, xScore;

  const PlayerInfo({super.key, required this.oScore, required this.xScore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          PlayerScore(playerSymbol: 'O', score: oScore),
          Spacer(),
          PlayerScore(playerSymbol: 'X', score: xScore),
        ],
      ),
    );
  }
}

class PlayerScore extends StatelessWidget {
  final String playerSymbol;
  final int score;

  const PlayerScore({
    super.key,
    required this.playerSymbol,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Player $playerSymbol', style: TextStyle(fontSize: 22.0)),
        Text('$score', style: TextStyle(fontSize: 22.0)),
      ],
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final void Function(String playerSymbol) onWin;

  const TicTacToeGame({super.key, required this.onWin});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGame();
}

class _TicTacToeGame extends State<TicTacToeGame> {
  bool _gameOver = false;
  bool _xTurn = true;
  List<String> moves = List.filled(9, '');

  String _playerSymbol() {
    return _xTurn ? 'X' : 'O';
  }

  void _newGame() {
    setState(() {
      moves = List.filled(9, '');
      _xTurn = true;
      _gameOver = false;
    });
  }

  void _takeTurn(index) {
    if (moves[index].isNotEmpty || _gameOver) return;

    setState(() {
      moves[index] = _playerSymbol();

      if (_checkWin()) {
        widget.onWin(_playerSymbol());
        _gameOver = true;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // TODO extract to widget that takes title msg
              title: Text('Player ${_playerSymbol()} Wins!'),
              content: const Text('Would you like to play again?'),
              actions: [
                TextButton(
                  child: const Text('See Board'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('New Game'),
                  onPressed: () {
                    _newGame();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (moves.every((move) => move.isNotEmpty)) {
        _gameOver = true;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // TODO see line 118 comment
              title: Text('Tie Game!'),
              content: const Text('Would you like to play again?'),
              actions: [
                TextButton(
                  child: const Text('See Board'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('New Game'),
                  onPressed: () {
                    _newGame();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        _xTurn = !_xTurn;
      }
    });
  }

  bool _checkWin() {
    final List<List<int>> winStates = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    return winStates.any((winState) {
      final [move0, move1, move2] = winState
          .map((index) => moves[index])
          .toList();
      return (move0.isNotEmpty && move0 == move1 && move1 == move2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderSide = const BorderSide(color: Colors.black, width: 0.5);
    return Column(
      spacing: 100,
      children: [
        Text("${_playerSymbol()}'s Turn", style: TextStyle(fontSize: 18.0)),
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: List.generate(9, (index) {
            final row = index ~/ 3;
            final col = index % 3;

            return GestureDetector(
              // TODO extract to widget
              onTap: () {
                _takeTurn(index);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    top: row > 0 ? borderSide : BorderSide.none,
                    bottom: row < 2 ? borderSide : BorderSide.none,
                    left: col > 0 ? borderSide : BorderSide.none,
                    right: col < 2 ? borderSide : BorderSide.none,
                  ),
                ),
                child: Text(moves[index], style: TextStyle(fontSize: 100.0)),
              ),
            );
          }),
        ),
        ElevatedButton(
          onPressed: () {
            _newGame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
          ),
          child: const Text('New Game'),
        ),
      ],
    );
  }
}
