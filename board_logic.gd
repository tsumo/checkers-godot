
extends Node2D

onready var board_nd = get_node("board")
onready var label_nd = get_node("label")

var black_piece_txtr = preload("images/black_piece.png")
var white_piece_txtr = preload("images/white_piece.png")

var piece_scn = preload("res://piece.scn")


func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		global.selected_piece_name = "None"
		global.selected_piece_pos = "None"


func _ready():
	set_process(true)
	set_process_input(true)
	
	randomize()
	
	for i in range(12):
		var piece = piece_scn.instance()
		piece.color = "black"
		var x = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
		var y = i / 4
		piece.set_pos(board_nd.map_to_world(Vector2(x[i], y)) + Vector2(32, 32))
		var sprite_nd = piece.get_node("sprite")
		sprite_nd.set_texture(black_piece_txtr)
		self.add_child(piece)


func _process(delta):
	label_nd.set_text(str("selected: ", global.selected_piece_name, " at ", global.selected_piece_pos))
