extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

class_name Pawn

var game 
var active : bool = false

signal moved

func initialize(game):
	self.game = game

func play_turn():
	if active:
		if game:
			game.logit(self.name + ": Its my turn")
		print(self.name + ": Its my turn")
	else:
		print(self.name + ": I wish I was active")
		