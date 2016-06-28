#
# Stores global state of the game
#

extends Node

var selected_piece_name = "None"
var selected_piece_pos = Vector2(-1, -1)
# May be uppercase for kings
var selected_piece_color = "None"

# Should always be lowercase
var current_player_color = "w"

# For multikill moves
var selection_blocked = false

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
