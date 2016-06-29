
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
		
		var pos = board_nd.world_to_map(event.pos - get_node("../root").get_pos())
		
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
				if has_capture_moves(global.selected_piece_name):
					block_selection()
				else:
					change_current_player()
					deselect_piece()
			# Stop event from propagating further
			self.get_tree().set_input_as_handled()


func _ready():
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
	var piece = get_node(global.selected_piece_name)
	piece.set_pos(new_pos)
	# Update global state
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
	global.state[x_from][y_from] = "-"
	global.state[x_to][y_to] = global.selected_piece_color
	global.selected_piece_pos = Vector2(x_to, y_to)
	# Crowning
	if global.selected_piece_color.to_lower() == "w" and y_to == 0 or \
	global.selected_piece_color.to_lower() == "b" and y_to == 7:
		crown(piece)


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


func has_normal_moves(piece_name):
	var piece = get_node(piece_name)
	var pos = board_nd.world_to_map(piece.get_pos())
	var x = pos.x
	var y = pos.y
	var i
	var j
	var diag
	
	if piece.crowned:
		diag = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
		for dir in diag:
			i = x
			j = y
			while (i + dir[0] >= 0 and i + dir[0] <= 7) and \
			(j + dir[1] >= 0 and j + dir[1] <= 7):
				i += dir[0]
				j += dir[1]
				if global.state[i][j] == "-":
					# Empty square found, piece has available moves
					return true
				else:
					# Other piece blocks the path
					return false
	else:
		if global.selected_piece_color.to_lower() == "b":
			diag = [[1, 1], [-1, 1]]
		else:
			diag = [[1, -1], [-1, -1]]
		for dir in diag:
			if (x + dir[0]) <= 7 and (y + dir[1]) <= 7 and \
			(x + dir[0]) >= 0 and (y + dir[1]) >= 0:
				if global.state[x + dir[0]][y + dir[1]] == "-":
					return true
	return false


func has_capture_moves(piece_name):
	var piece = get_node(piece_name)
	var pos = board_nd.world_to_map(piece.get_pos())
	var x = pos.x
	var y = pos.y
	var i
	var j
	var diag = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
	var enemy_piece_found
	var friendly_piece_found
	var multiple_pieces_found
	
	# Check every diagonal direction
	for dir in diag:
		i = x
		j = y
		if piece.crowned:
			enemy_piece_found = false
			friendly_piece_found = false
			multiple_pieces_found = false
			while (i + dir[0] >= 0 and i + dir[0] <= 7) and \
			(j + dir[1] >= 0 and j + dir[1] <= 7):
				i += dir[0]
				j += dir[1]
				# Same color piece found on the path
				if global.state[i][j].to_lower() == global.current_player_color:
					friendly_piece_found = true
				# Enemy piece on the path
				if global.state[i][j].to_lower() == inv_color(global.current_player_color):
					# Can't move through multiple pieces at once
					if enemy_piece_found:
						multiple_pieces_found = true
					else:
						enemy_piece_found = true
				# Empty square found after the enemy piece
				if global.state[i][j] == "-":
					if enemy_piece_found and \
					not multiple_pieces_found and \
					not friendly_piece_found:
						return true
		else:
			# Check for enemy piece nearby
			if (x + dir[0]) <= 7 and (y + dir[1]) <= 7 and \
			(x + dir[0]) >= 0 and (y + dir[1]) >= 0 and \
			global.state[x + dir[0]][y + dir[1]].to_lower() == \
			inv_color(global.current_player_color):
				# Check for empty square after enemy piece
				if (x + dir[0]*2) <= 7 and (y + dir[1]*2) <= 7 and \
				(x + dir[0]*2) >= 0 and (y + dir[1]*2) >= 0 and \
				global.state[x+dir[0]*2][y+dir[1]*2] == "-":
					return true
	return false


func is_valid_move(pos):
	# Normal moves allowed only for non-blocked pieces
	if global.selection_blocked == true:
		return false
	
	# Normal moves not allowed when capture moves are available
	if has_capture_moves(global.selected_piece_name):
		return false
	
	var piece = get_node(global.selected_piece_name)
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
	var x = x_from
	var y = y_from
	var diag
	var result = true
	
	# Check for non-diagonal move
	if abs(x_from - x_to) != abs(y_from - y_to):
		return false
	
	if global.selected_piece_color.to_lower() == "b":
		diag = [[1, 1], [-1, 1]]
	else:
		diag = [[1, -1], [-1, -1]]
	
	if piece.crowned:
		# Go through all squares in between current pos
		# and destination pos
		while x != x_to:
			if x < x_to:
				x += 1
			else:
				x -= 1
			if y < y_to:
				y += 1
			else:
				y -= 1
			# Non-empty square found on the path
			if global.state[x][y] != "-":
				result = false
	else:
		# Checking appropriate diagonal direction for current piece
		for dir in diag:
			# Normal pieces can do only one diagonal step
			if x_to != x_from + dir[0] and y_to != y_from + dir[1]:
				result = false
	
	return result


func is_valid_capture_move(pos):
	var piece = get_node(global.selected_piece_name)
	var x_from = global.selected_piece_pos.x
	var y_from = global.selected_piece_pos.y
	var x_to = pos.x
	var y_to = pos.y
	var x = x_from
	var y = y_from
	var enemy_piece_found = false
	var result = false
	
	# Check for non-diagonal move
	if abs(x_from - x_to) != abs(y_from - y_to):
		return false
	
	if piece.crowned:
		# Go through all squares in between current pos
		# and destination pos
		while x != x_to:
			if x < x_to:
				x += 1
			else:
				x -= 1
			if y < y_to:
				y += 1
			else:
				y -= 1
			# Same color piece blocks the path
			if global.state[x][y].to_lower() == global.current_player_color:
				return false
			# Enemy piece on the path
			if global.state[x][y].to_lower() == inv_color(global.current_player_color):
				# Can't move through multiple pieces at once
				if enemy_piece_found:
					return false
				else:
					enemy_piece_found = true
			# Empty square found after the enemy piece
			if global.state[x][y] == "-":
				if enemy_piece_found:
					result = true
	else:
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
				# Check for enemy piece
				if global.state[x][y].to_lower() == inv_color(global.current_player_color):
					return true
	return result


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


func crown(piece):
	piece.get_node("crown").show()
	piece.crowned = true
	var pos = board_nd.world_to_map(piece.get_pos())
	var x = pos.x
	var y = pos.y
	global.state[x][y] = global.state[x][y].to_upper()
	piece.color = piece.color.to_upper()


func remove_piece(name):
	var piece = get_node(name)
	var x = board_nd.world_to_map(piece.get_pos()).x
	var y = board_nd.world_to_map(piece.get_pos()).y
	global.state[x][y] = "-"
	piece.free()


func inv_color(color):
	if color == "b":
		return "w"
	elif color == "w":
		return "b"
	elif color == "B":
		return "W"
	elif color == "W":
		return "B"


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
	if global.selected_piece_name != "None":
		print("Has normal moves: ", has_normal_moves(global.selected_piece_name))
		print("Has capture moves: ", has_capture_moves(global.selected_piece_name))
	for i in range(8):
		var state_line = ""
		for j in range(8):
			if j == global.selected_piece_pos.x and i == global.selected_piece_pos.y:
				state_line += "(" + global.state[j][i] + ")\t"
			else:
				state_line += global.state[j][i] + "\t"
		print(state_line)
