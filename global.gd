#
# Stores global state of the game
#

extends Node

var white_pieces = []
var black_pieces = []

var piece = preload("res://white_piece.scn").instance()

var selected_piece_pos
var selected_piece_name

func _ready():
	for i in range(12):
		pass
	get_node(".").add_child(piece)
	#white_pieces[0].pos = Vector2(30, 30)
	


