#
# Stores global state of the game
#

extends Node

var selected_piece_name = "None"
var selected_piece_pos = "None"
var selected_piece_color = "None"

# Stores positions of pieces
var state = []


func _ready():
	# Dash for empty square
	# w for white piece
	# b for black piece
	for i in range(8):
		state.append([])
		for j in range(8):
			state[i].append("-")
