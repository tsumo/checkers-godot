
extends Label

#onready var label = get_node(self)

func _ready():
	set_process(true)

func _process(delta):
	self.set_text(str("Mode: ", Input.get_mouse_mode(), "Speed: ", Input.get_mouse_speed()))
