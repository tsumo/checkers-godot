
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
		and is_on_board(event.pos) \
		and is_empty_square(event.pos):
			if is_valid_move(event.pos):
				move_selected_to(event.pos)
				deselect_piece()
				change_current_player()
			elif is_valid_capture_move(event.pos):
				move_selected_to(event.pos)
				capture_from_current_to(event.pos)
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
		piece.add_to_group("w")
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
		piece.add_to_group("b")
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


func is_on_board(pos):
	var x = board_nd.world_to_map(pos).x
	var y = board_nd.world_to_map(pos).y
	if (x >= 0 and x <= 7) and (y >= 0 and y <= 7):
		return true
	else:
		return false


# TO DO
func has_moves(piece_pos):
	var x = board_nd.world_to_map(piece_pos).x
	var y = board_nd.world_to_map(piece_pos).y


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
	var x = x_from
	var y = y_from
	if abs(x_from - x_to) == 2 and abs(y_from - y_to) == 2:
		# Go through all squares in between current pos
		# and destination pos
		while(x != x_to):
			if x < x_to:
				x += 1
			else:
				x -= 1
			if y < y_to:
				y += 1
			else:
				y -= 1
			# Go through all opposite color pieces
			for piece in get_tree().get_nodes_in_group(inv_color(global.current_player_color)):
				if board_nd.world_to_map(piece.get_pos()) == Vector2(x, y):
					return true
	return false


func capture_from_current_to(pos):
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = board_nd.world_to_map(pos).x
	var y_to = board_nd.world_to_map(pos).y
	var x = x_from
	var y = y_from
	# Go through all squares in between current pos
	# and destination pos
	while(x != x_to):
		if x < x_to:
			x += 1
		else:
			x -= 1
		if y < y_to:
			y += 1
		else:
			y -= 1
		# Go through all opposite color pieces
		for piece in get_tree().get_nodes_in_group(inv_color(global.current_player_color)):
			if board_nd.world_to_map(piece.get_pos()) == Vector2(x, y):
				remove_piece(piece.get_name())


func remove_piece(name):
	var piece = get_node(name)
	var x = board_nd.world_to_map(piece.get_pos()).x
	var y = board_nd.world_to_map(piece.get_pos()).y
	global.state[x][y] = "-"
	piece.queue_free()


func inv_color(color):
	if color == "b":
		return "w"
	else:
		return "b"


func change_current_player():
	global.current_player_color = inv_color(global.current_player_color)
	label_nd.set_text("Current player: " + global.current_player_color)


func print_board_state():
	print("Current player: ", global.current_player_color)
	for i in range(8):
		var state_line = ""
		for j in range(8):
			state_line += global.state[j][i] + " "
		print(state_line)
