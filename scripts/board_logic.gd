
extends Node2D

onready var board_nd = get_node("board")
onready var label_nd = get_node("label")

var black_piece_txtr = preload("res://images/black_piece.png")
var white_piece_txtr = preload("res://images/white_piece.png")

var piece_scn = preload("res://scenes/piece.xml")
var highlight_scn = preload("res://scenes/highlight.xml")


func _input(event):
	# Exit by ESC
	if event.type == InputEvent.KEY \
	and event.scancode == KEY_ESCAPE:
		get_tree().quit()
	
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_WHEEL_DOWN:
		print_board_state()
	
	# Right click to deselect
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_RIGHT \
	and event.pressed:
		if global.selected_piece_name != "None":
			deselect_piece()
	
	# Left click to move selected piece
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		if global.selected_piece_name != "None" \
		and is_empty_square(event.pos):
			if is_valid_move(event.pos):
				move_selected_to(event.pos)
				deselect_piece()
				change_current_player()
			elif is_valid_capture_move(event.pos):
				move_selected_to(event.pos)
				if board_nd.world_to_map(event.pos).x > global.selected_piece_pos.x:
					capture_right()
				if board_nd.world_to_map(event.pos).x < global.selected_piece_pos.x:
					capture_left()
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
	pass


# Instance and position white pieces
func init_white():
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "w"
		piece.add_to_group("white_grp")
		piece.add_to_group("pieces_grp")
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
		piece.add_to_group("black")
		piece.add_to_group("pieces_grp")
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


func is_empty_square(pos):
	var x = board_nd.world_to_map(pos).x
	var y = board_nd.world_to_map(pos).y
	if global.state[x][y] == "-":
		return true
	else:
		return false


func is_valid_move(pos):
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = board_nd.world_to_map(pos).x
	var y_to = board_nd.world_to_map(pos).y
	if global.current_player_color == "b":
		# Allow diagonal moves down only
		if y_to == y_from + 1 and \
		(x_to == x_from - 1 or x_to == x_from + 1):
			return true
		else:
			return false
	else:
		# Same for white pieces, only diagonal moves up
		if y_to == y_from - 1 and \
		(x_to == x_from - 1 or x_to == x_from + 1):
			return true
		else:
			return false


func is_valid_capture_move(pos):
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = board_nd.world_to_map(pos).x
	var y_to = board_nd.world_to_map(pos).y
	var piece_on_the_left = "-"
	var piece_on_the_right = "-"
	if global.current_player_color == "b":
		# Get color of the adjacent pieces
		# Don't check if piece is on the edge of the board
		if x_from != 0 and y_from != 7:
			piece_on_the_left = global.state[x_from-1][y_from+1]
		if x_from != 7 and y_from != 7:
			piece_on_the_right = global.state[x_from+1][y_from+1]
		# Two squares down
		if y_to == y_from + 2:
			# Look for another player's piece on diagonal squares
			if (x_to == x_from - 2 and piece_on_the_left == "w") or \
			(x_to == x_from + 2 and piece_on_the_right == "w"):
				return true
			else:
				return false
		else:
			return false
	else:
		# Same logic for white pieces
		if x_from != 0  and y_from != 0:
			piece_on_the_left = global.state[x_from-1][y_from-1]
		if x_from != 7 and y_from != 0:
			piece_on_the_right = global.state[x_from+1][y_from-1]
		if y_to == y_from - 2:
			if (x_to == x_from - 2 and piece_on_the_left == "b") or \
			(x_to == x_from + 2 and piece_on_the_right == "b"):
				return true
			else:
				return false
		else:
			return false


func capture_left():
	for piece in get_tree().get_nodes_in_group("pieces_grp"):
		if global.current_player_color == "b":
			if board_nd.world_to_map(piece.get_pos()) == global.selected_piece_pos + Vector2(-1, 1):
				remove_piece(piece.get_name())
		if global.current_player_color == "w":
			if board_nd.world_to_map(piece.get_pos()) == global.selected_piece_pos + Vector2(-1, -1):
				remove_piece(piece.get_name())


func capture_right():
	for piece in get_tree().get_nodes_in_group("pieces_grp"):
		if global.current_player_color == "b":
			if board_nd.world_to_map(piece.get_pos()) == global.selected_piece_pos + Vector2(1, 1):
				remove_piece(piece.get_name())
		if global.current_player_color == "w":
			if board_nd.world_to_map(piece.get_pos()) == global.selected_piece_pos + Vector2(1, -1):
				remove_piece(piece.get_name())


func remove_piece(name):
	var piece = get_node(name)
	var x = board_nd.world_to_map(piece.get_pos()).x
	var y = board_nd.world_to_map(piece.get_pos()).y
	global.state[x][y] = "-"
	piece.queue_free()


func change_current_player():
	if global.current_player_color == "w":
		global.current_player_color = "b"
		label_nd.set_text("Current player: b")
	else:
		global.current_player_color = "w"
		label_nd.set_text("Current player: w")


func print_board_state():
	print("Current player: ", global.current_player_color)
	for i in range(8):
		var state_line = ""
		for j in range(8):
			state_line += global.state[j][i] + " "
		print(state_line)
