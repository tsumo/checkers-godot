
extends Node2D

#var mouse_pos

#onready var board = get_node("../board")

var white_pieces = []
var black_pieces = []

var piece = preload("res://piece.scn")

func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		pass

func _ready():
	set_process(true)
	
	randomize()
	
	for i in range(12):
		var tmp = piece.instance()
		tmp.set_pos(Vector2(150,150)+Vector2(randf()*200-3,randf()*200-3))
		self.add_child(tmp)

func _process(delta):
	#mouse_pos = get_viewport().get_mouse_pos()
	#print(get_children())
	pass