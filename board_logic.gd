
extends Node2D

var white_pieces = []
var black_pieces = []

onready var label_nd = get_node("label")

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
		piece.set_pos(Vector2(150,150)+Vector2(randf()*300-3,randf()*300-3))
		self.add_child(piece)


func _process(delta):
	label_nd.set_text(str("selected: ", global.selected_piece_name, " at ", global.selected_piece_pos))


func position_pieces():
	