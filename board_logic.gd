
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
		print_state()
		if global.selected_piece_name != "None":
			global.selected_piece_name = "None"
			global.selected_piece_pos = "None"
			global.selected_piece_color = "None"


func _ready():
	set_process(true)
	set_process_input(true)
	
	randomize()
	
	# Instance and position black pieces
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "b"
		var x = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
		var y = i / 4
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)) + Vector2(32, 32))
		global.state[y][x[i]] = "b"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(black_piece_txtr)
		self.add_child(piece)
	
	# # Instance and position white pieces
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "w"
		var x = [0, 2, 4, 6, 1, 3, 5, 7, 0, 2, 4, 6]
		var y = (i / 4) + 5
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)) + Vector2(32, 32))
		global.state[y][x[i]] = "w"
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(white_piece_txtr)
		self.add_child(piece)


func _process(delta):
	label_nd.set_text(str("selected: ", global.selected_piece_name))
	label_nd.set_text(label_nd.get_text() + str(" at: ", global.selected_piece_pos))
	label_nd.set_text(label_nd.get_text() + str(" color: ", global.selected_piece_color))


func print_state():
	print("State:")
	for i in global.state:
		print(i)