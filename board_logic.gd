
extends Node2D

var mouse_pos

onready var tilemap = get_node("board")

func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		pass

func _ready():
	set_process(true)

func _process(delta):
	mouse_pos = get_viewport().get_mouse_pos()
	