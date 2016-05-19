
extends Area2D

var color = "white"
var pos
var selected = false

onready var sprite = get_node("piece")
onready var tilemap = get_node("../board")
onready var label = get_node("../text")

func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		global.selected_piece = tilemap.world_to_map(pos)

func _mouse_enter():
	sprite.set_scale(Vector2(1.1, 1.1))

func _mouse_exit():
	sprite.set_scale(Vector2(1, 1))

func _ready():
	self.set_process(true)

func _process(delta):
	pos = self.get_pos()
	if global.selected_piece == tilemap.world_to_map(pos):
		selected = true
	else:
		selected = false
	
	if selected:
		sprite.set_modulate(Color(1.2, 1, 1, 1))
	else:
		sprite.set_modulate(Color(1, 1, 1, 1))

