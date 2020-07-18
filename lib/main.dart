// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

int oWins = 0;
int xWins = 0; 

// This is the main app widget, which immediately opens the StartPage widget.
class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: "Welcome",
			home: StartPage(),
		);
	}
}

// This is the StartPage widget, which includes a "New Game" and "Reset Statistics" button.
class StartPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: CupertinoNavigationBar(
				middle: Text("Welcome"),
			),
			body: Column(
				mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				children: <Widget>[
					Center(
						child: CupertinoButton.filled(
							child: Text("New Game"), 
							disabledColor: Colors.blue,
							onPressed: () {
								Navigator.push(
									context,
									MaterialPageRoute(builder: (context) => Game())
								);
							}
						),
					),
					Center(
						child: CupertinoButton.filled(
							child: Text("Reset Statistics"), 
							disabledColor: Colors.blue,
							onPressed: () {
								oWins = 0;
								xWins = 0;
								showDialog(
									context: context,
									builder: (BuildContext context) => new CupertinoAlertDialog(
										title: Text("Statistics Reset"),
										actions: <Widget>[
											CupertinoDialogAction(
												isDefaultAction: true,
												child: new Text("Close"),
												onPressed: () => Navigator.pop(context),
											),
										],
									),
								);
							}
						),
					),
				],
			),
		);
	}
}

//The Game widget contains the main TicTacToe game and all of its corresponding logic.
class Game extends StatefulWidget {
	@override
	_GameState createState() => _GameState();
}

//Since this is a stateful widget, the _GameState class monitors the state of the board.
class _GameState extends State<Game> {
	List<int> boardState;
	int player;

	//List of tile combinations that are wins
	List<List<int>> winConditions = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];

	//Starts the game by setting all 9 tiles to be empty
	@override
	void initState() {
		super.initState();
		boardState = List.filled(9, 0, growable: false);
		player = 1;
	}

	//Main user interface of the game
	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			child: Scaffold(
				appBar: CupertinoNavigationBar(
					middle: Text("TicTacToe"),
				),
				body: Column(
					children: <Widget>[
						Padding(
							padding: const EdgeInsets.all(30),
							child: Row(
								children: <Widget>[
									Expanded(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Align(
													alignment: Alignment.topLeft,
													child: Text(
														"Player O",
													)
												),
												Align(
													alignment: Alignment(-0.7, 0),
													child: Text(
														"$oWins",
													)
												),
											],
										)
									),
									Expanded(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Align(
													alignment: Alignment.topRight,
													child: Text(
														"Player X",
													)
												),
												Align(
													alignment: Alignment(0.7, 0),
													child: Text(
														"$xWins",
													)
												),
											],
										)
									),
								],
							),
						),
						Expanded(
							child: GridView.count(
								crossAxisCount: 3,
								children: List.generate(9, (index) {
									String name = "";
									if (boardState[index] == 1) {
										name = "X";
									}
									else if (boardState[index] == 2){
										name = "O";
									}
									else {
										name = "";
									}
									return TicTacToeTile(index: index, tapFunction: onTileTap, tileName: name);
								}),
							)
						)
					],
				)
			), 
			onWillPop: () => showDialog<bool>(
				context: context,
				builder: (choice) => CupertinoAlertDialog(
					title: Text("Are you sure you want to quit the game?"),
					content: Text("Any moves you have made will not be saved."),
					actions: <Widget>[
						CupertinoDialogAction(
							onPressed: () => Navigator.pop(choice, true), 
							child: Text(
								"Yes",
								style: TextStyle(
									color: Colors.red,
								),
							),
						),
						CupertinoDialogAction(
							isDefaultAction: true,
							onPressed: () => Navigator.pop(choice, false), 
							child: Text("No"),
						),
					],
				)
			)
		);
	}

	//This function is run when a tile is tapped. 
	//It updates the value of the tile and checks the board for any possible win/draw.
	void onTileTap(int index) {
		setState(() {
			boardState[index] = player;

			if (player == 1) {
				player = 2;
				checkWin();
				checkDraw();
			}
			else if (player == 2) {
				player = 1;
				checkWin();
				checkDraw();
			}
		});
	}

	//This function checks the board to see if there is a win or draw present.
	void checkWin() {
		for (int i = 0; i < winConditions.length; i++) {
			if (boardState[winConditions[i][0]] == boardState[winConditions[i][1]] && boardState[winConditions[i][1]] == boardState[winConditions[i][2]] && boardState[winConditions[i][1]] != 0) {
				String winner = "", nextFirst = "";
				if (boardState[winConditions[i][0]] == 1) {
					xWins += 1;
					winner = "X";
					nextFirst = "O";
				}
				else if (boardState[winConditions[i][0]] == 2) {
					oWins += 1;
					winner = "O";
					nextFirst = "X";
				}
				showDialog(
					context: context,
					builder: (BuildContext context) => new CupertinoAlertDialog(
						title: Text("Player $winner Wins!"),
						content: Text("Player $nextFirst will go first next time."),
						actions: <Widget>[
							CupertinoDialogAction(
								isDefaultAction: true,
								child: new Text("Restart"),
								onPressed: () => Navigator.pop(context),
							)
						],
					),
				);

				//Resets board
				boardState = List.filled(9, 0, growable: false);
			}
		}
	}

	void checkDraw() {
		//Counts the number of empty squares
		int emptyCount = 0;
		for (int tile in boardState) {
			if (tile == 0) {
				emptyCount += 1;
			}
		}

		//If the board is full, call a draw
		if (emptyCount == 0) {
			showDialog(
				context: context,
				builder: (BuildContext context) => new CupertinoAlertDialog(
					title: Text("Draw!"),
					content: Text("Better luck next time!"),
					actions: <Widget>[
						CupertinoDialogAction(
							isDefaultAction: true,
							child: new Text("Restart"),
							onPressed: () => Navigator.pop(context),
						)
					],
				),
			);

			//Resets board
			boardState = List.filled(9, 0, growable: false);
		}
	}
}

//This class includes the informatino for the tile and grid.
class TicTacToeTile extends StatelessWidget {
	final int index;
	final String tileName;
	final Function(int index) tapFunction;

	//Constructor
	TicTacToeTile({this.index, this.tapFunction, this.tileName});

	//Calls designated onTap() function when the tile is tapped.
	void tileTapped() {
		if (tileName == "") {
			tapFunction(index);
		}
	}

	//This sets the locations of the grid markers.
	Border getBorderLayout() {
		if (index == 0) {
			//Top Left
			return Border(bottom: BorderSide(width: 0.5), right: BorderSide(width: 0.5));
		}
		else if (index == 1) {
			//Top Center
			return Border(left: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5), right: BorderSide(width: 0.5));
		}
		else if (index == 2) {
			//Top Right
			return Border(left: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5));
		}
		else if (index == 3) {
			//Center Left
			return Border(bottom: BorderSide(width: 0.5), right: BorderSide(width: 0.5), top: BorderSide(width: 0.5));
		}
		else if (index == 4) {
			//Center
			return Border(left: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5), right: BorderSide(width: 0.5), top: BorderSide(width: 0.5));
		}
		else if (index == 5) {
			//Center Right
			return Border(left: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5), top: BorderSide(width: 0.5));
		}
		else if (index == 6) {
			//Bottom Left
			return Border(right: BorderSide(width: 0.5), top: BorderSide(width: 0.5));
		}
		else if (index == 7) {
			//Bottom Center
			return Border(left: BorderSide(width: 0.5), top: BorderSide(width: 0.5), right: BorderSide(width: 0.5));
		}
		else if (index == 8) {
			//Bottom Right
			return Border(left: BorderSide(width: 0.5), top: BorderSide(width: 0.5));
		}
		else {
			return Border.all();
		}
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
				onTap: tileTapped,
				child: Container(
					margin: null,
					decoration: BoxDecoration(
						border: getBorderLayout()
					),
					child: Center(
						child: Text(
							tileName, 
							style: TextStyle(
								fontSize: 50, 
								fontWeight: FontWeight.bold
							)
						)
					),
				),
		);
	}
}
