
extends Node2D

onready var board_nd = get_node("board")
onready var label_nd = get_node("label")

var black_piece_txtr = preload("res://images/black_piece.png")
var white_piece_txtr = preload("res://images/white_piece.png")

var piece_scn = preload("res://scenes/piece.xml")


func _input(event):
	# Exit by ESC
	if event.type == InputEvent.KEY \
	and event.scancode == KEY_ESCAPE:
		get_tree().quit()
	
	# Wheel down to print game status
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_WHEEL_DOWN:
		print_board_state()
	
	# Right click to deselect
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_RIGHT \
	and event.pressed:
		if global.selected_piece_name != "None" and \
		global.selection_blocked == false:
			deselect_piece()
	
	# Left click to move selected piece
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		
		var pos = board_nd.world_to_map(event.pos)
		
		if global.selected_piece_name != "None" \
		and is_on_board(pos) \
		and is_empty_square(pos):
			if is_valid_move(pos):
				move_selected_to(pos)
				change_current_player()
				deselect_piece()
			elif is_valid_capture_move(pos):
				capture_from_current_to(pos)
				move_selected_to(pos)
				if has_capture_moves(pos):
					block_selection()
				else:
					change_current_player()
					deselect_piece()
			# Stop event from propagating further
			self.get_tree().set_input_as_handled()


func _ready():
	randomize()
	
	set_process(true)
	set_process_input(true)
	
	init_black()
	init_white()
	
	# Center game window
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func _process(delta):
	pass


# Instance and position white pieces
func init_white():
	var x = [0, 2, 4, 6, 1, 3, 5, 7, 0, 2, 4, 6]
	for i in range(12):
		var y = (i / 4) + 5
		var piece = piece_scn.instance()
		piece.color = "w"
		piece.add_to_group("w")
		piece.add_to_group("pieces_grp")
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)))
		global.state[x[i]][y] = "w"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(white_piece_txtr)
		self.add_child(piece)


# Instance and position black pieces
func init_black():
	var x = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
	for i in range(12):
		var y = i / 4
		var piece = piece_scn.instance()
		piece.color = "b"
		piece.add_to_group("b")
		piece.add_to_group("pieces_grp")
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)))
		global.state[x[i]][y] = "b"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(black_piece_txtr)
		self.add_child(piece)


func deselect_piece():
	global.selected_piece_name = "None"
	global.selected_piece_pos = Vector2(-1, -1)
	global.selected_piece_color = "None"
	global.selection_blocked = false


func block_selection():
	global.selection_blocked = true


func move_selected_to(pos):
	var new_pos = board_nd.map_to_world(pos)
	get_node(global.selected_piece_name).set_pos(new_pos)
	# Update global state
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
	global.state[x_from][y_from] = "-"
	global.state[x_to][y_to] = global.selected_piece_color
	global.selected_piece_pos = Vector2(x_to, y_to)


func is_empty_square(pos):
	if global.state[pos.x][pos.y] == "-":
		return true
	else:
		return false


func is_on_board(pos):
	if (pos.x >= 0 and pos.x <= 7) and (pos.y >= 0 and pos.y <= 7):
		return true
	else:
		return false


func has_capture_moves(pos):
	print("Checking for moves at ", pos)
	var x = pos.x
	var y = pos.y
	var diag = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
	# Check every diagonal direction
	for dir in diag:
		print("  Checking dir ", dir)
		# Check for enemy piece nearby
		print("  Checking at ", x + dir[0], " ", y + dir[1])
		if (x + dir[0]) <= 7 and (y + dir[1]) <= 7 and \
		(x + dir[0]) >= 0 and (y + dir[1]) >= 0 and \
		global.state[x + dir[0]][y + dir[1]] == inv_color(global.current_player_color):
			print("    Found enemy at ", x+dir[0], " ", y+dir[1])
			# Check for empty square after enemy piece
			if (x + dir[0]*2) <= 7 and (y + dir[1]*2) <= 7 and \
			(x + dir[0]*2) >= 0 and (y + dir[1]*2) >= 0 and \
			global.state[x+dir[0]*2][y+dir[1]*2] == "-":
				print("      Found empty space at ", x+dir[0]*2, " ", y+dir[1]*2)
				return true
	return false


func is_valid_move(pos):
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
	# Normal moves allowed only for non-blocked pieces
	if global.selection_blocked == false:
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
	else:
		return false


func is_valid_capture_move(pos):
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
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
	var x_to = pos.x
	var y_to = pos.y
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
	piece.free()


func inv_color(color):
	if color == "b":
		return "w"
	else:
		return "b"


func change_current_player():
	global.current_player_color = inv_color(global.current_player_color)
	if global.current_player_color == "b":
		label_nd.set_text("Current player: black")
	else:
		label_nd.set_text("Current player: white")


func print_board_state():
	print("Current player: ", global.current_player_color)
	print("Selected pos: ", global.selected_piece_pos)
	print("Selected name: ", global.selected_piece_name)
	print("Selection blocked: ", global.selection_blocked)
	for i in range(8):
		var state_line = ""
		for j in range(8):
			if j == global.selected_piece_pos.x and i == global.selected_piece_pos.y:
				state_line += global.state[j][i].to_upper() + "\t"
			else:
				state_line += global.state[j][i] + "\t"
		print(state_line)
