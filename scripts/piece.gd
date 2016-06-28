#
# Individual piece logic
#

extends Area2D

var color
var pos
var selected = false
var crowned = false

onready var sprite_nd = get_node("sprite")
onready var crown_nd = get_node("crown")
onready var board_nd = get_node("../board")

# Material gets duplicated to allow different shaders on
# multiple instances of scene
onready var piece_material = sprite_nd.get_material().duplicate()
var outline_shader = preload("res://res/outline_shader.xml")
var empty_shader = preload("res://res/empty_shader.xml")


# Handles click on piece - updates global state
func _input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		if global.current_player_color == color.to_lower() and \
		global.selection_blocked == false:
			select()



func select():
	# self is used to allow this function to be called from other scripts
	global.selected_piece_name = self.get_name()
	global.selected_piece_pos = board_nd.world_to_map(self.pos)
	global.selected_piece_color = self.color


func _mouse_enter():
	if global.current_player_color == color.to_lower():
		sprite_nd.set_scale(Vector2(1.1, 1.1))
		crown_nd.set_scale(Vector2(1.1, 1.1))


func _mouse_exit():
	if global.current_player_color == color.to_lower():
		sprite_nd.set_scale(Vector2(1, 1))
		crown_nd.set_scale(Vector2(1, 1))


func _ready():
	self.set_process(true)
	
	# Material to hold shader
	sprite_nd.set_material(piece_material)
	sprite_nd.get_material().set_shader(empty_shader)


func _process(delta):
	pos = self.get_pos()
	
	if global.selected_piece_name == self.get_name():
		selected = true
	else:
		selected = false
	
	# Visual selection
	if selected:
		piece_material.set_shader(outline_shader)
	else:
		piece_material.set_shader(empty_shader)
		