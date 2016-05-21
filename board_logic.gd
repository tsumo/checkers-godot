
extends Node2D

var white_pieces = []
var black_pieces = []

var piece_scn = preload("res://piece.scn")


func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		pass


func _ready():
	set_process(true)
	
	randomize()
	
	for i in range(12):
		var piece = piece_scn.instance()
		piece.set_pos(Vector2(150,150)+Vector2(randf()*300-3,randf()*300-3))
		self.add_child(piece)


func _process(delta):
	pass


func position_pieces():
	