#
# Individual piece logic
#

extends Area2D

var color
var pos
var selected = false

onready var sprite_nd = get_node("sprite")
onready var board_nd = get_node("../board")


func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		global.selected_piece_pos = board_nd.world_to_map(pos)
		global.selected_piece_name = self.get_name()


func _mouse_enter():
	sprite_nd.set_scale(Vector2(1.1, 1.1))


func _mouse_exit():
	sprite_nd.set_scale(Vector2(1, 1))


func _ready():
	self.set_process(true)


func _process(delta):
	pos = self.get_pos()
	if global.selected_piece_name == self.get_name():
		selected = true
	else:
		selected = false
	
	if selected:
		sprite_nd.set_modulate(Color(1.2, 1, 1, 1))
	else:
		sprite_nd.set_modulate(Color(1, 1, 1, 1))
		
