extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

class_name Pawn

var game 
var active : bool = false
var speed : int = 0
var moves_left : int = 0

signal end_of_turn

func initialize(game):
	self.game = game

func play_turn():
	self.moves_left = self.speed 
	
	if game:
		game.logit(self.name + ": Its my turn")

		