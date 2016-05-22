
extends Node2D

onready var board_nd = get_node("board")
onready var label_nd = get_node("label")

var black_piece_txtr = preload("images/black_piece.png")
var white_piece_txtr = preload("images/white_piece.png")

var piece_scn = preload("res://piece.scn")


func _input(event):
	# Exit by ESC
	if event.type == InputEvent.KEY \
	and event.scancode == KEY_ESCAPE:
		get_tree().quit()
	
	# Right click to deselect
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_RIGHT \
	and event.pressed:
		print_board_state()
		if global.selected_piece_name != "None":
			deselect_piece()
	
	# Left click to move selected piece
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		if global.selected_piece_name != "None":
			move_selected_to(event.pos)
			deselect_piece()
			change_current_player()
			# Stop event from propagating further
			self.get_tree().set_input_as_handled()


func _ready():
	set_process(true)
	set_process_input(true)
	
	randomize()
	
	init_black()
	init_white()


func _process(delta):
	label_nd.set_text(str("selected: ", global.selected_piece_name))
	label_nd.set_text(label_nd.get_text() + str(" at: ", global.selected_piece_pos))
	label_nd.set_text(label_nd.get_text() + str(" color: ", global.selected_piece_color))


# Instance and position white pieces
func init_white():
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "w"
		var x = [0, 2, 4, 6, 1, 3, 5, 7, 0, 2, 4, 6]
		var y = (i / 4) + 5
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)) + Vector2(32, 32))
		global.state[x[i]][y] = "w"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(white_piece_txtr)
		self.add_child(piece)


# Instance and position black pieces
func init_black():
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "b"
		var x = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
		var y = i / 4
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)) + Vector2(32, 32))
		global.state[x[i]][y] = "b"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(black_piece_txtr)
		self.add_child(piece)


func deselect_piece():
	global.selected_piece_name = "None"
	global.selected_piece_pos = "None"
	global.selected_piece_color = "None"


func move_selected_to(pos):
	# Transform global click pos to board coordinates and back
	# to move piece exactly to the clicked square.
	# Add offset to position it in center of the square
	get_node(global.selected_piece_name).set_pos(board_nd.map_to_world(board_nd.world_to_map(pos)) + Vector2(32, 32))
	# Update global state
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = board_nd.world_to_map(pos).x
	var y_to = board_nd.world_to_map(pos).y
	global.state[x_from][y_from] = "-"
	global.state[x_to][y_to] = global.selected_piece_color


func change_current_player():
	if global.current_player_color == "w":
		global.current_player_color = "b"
	else:
		global.current_player_color = "w"


func print_board_state():
	print("Current player: ", global.current_player_color)
	for i in range(8):
		var state_line = ""
		for j in range(8):
			state_line += global.state[j][i] + " "
		print(state_line)
