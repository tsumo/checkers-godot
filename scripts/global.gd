#
# Stores global state of the game
#

extends Node

#var screen_size = OS.get_screen_size(screen=0)
#var window_size = OS.get_window_size()
#OS.set_window_position(screen_size*0.5 - window_size*0.5)

var selected_piece_name = "None"
var selected_piece_pos = Vector2(-1, -1)
var selected_piece_color = "None"

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
