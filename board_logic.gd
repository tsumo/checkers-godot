#
#extends Node2D
#
#var white_pieces = []
#var black_pieces = []
#
#class white_piece:
#	onready var piece = get_node("res://piece/white_piece")
#
#func _draw():
#	var white = preload("res://images/white_piece.png")
#	var black = preload("res://images/black_piece.png")
#	var mouse_pos = get_viewport().get_mouse_pos()
#	
#	for piece in white_pieces:
#		draw_texture(white, piece.pos * 64 - Vector2(64, 64))
#	for piece in black_pieces:
#		draw_texture(black, piece.pos * 64 - Vector2(64, 64))
#
#func _process(delta):
#	update()
#
#func _ready():
#	for i in range(12):
#		white_pieces.append(white_piece.new())
#		print(white_pieces[i].get_name())
#	
#	white_pieces[0].piece.pos = Vector2(1, 6)
#	white_pieces[1].pos = Vector2(1, 8)
#	white_pieces[2].pos = Vector2(2, 7)
#	white_pieces[3].pos = Vector2(3, 6)
#	white_pieces[4].pos = Vector2(3, 8)
#	white_pieces[5].pos = Vector2(4, 7)
#	white_pieces[6].pos = Vector2(5, 6)
#	white_pieces[7].pos = Vector2(5, 8)
#	white_pieces[8].pos = Vector2(6, 7)
#	white_pieces[9].pos = Vector2(7, 6)
#	white_pieces[10].pos = Vector2(7, 8)
#	white_pieces[11].pos = Vector2(8, 7)
#	
#	black_pieces[0].pos = Vector2(1, 2)
#	black_pieces[1].pos = Vector2(2, 1)
#	black_pieces[2].pos = Vector2(2, 3)
#	black_pieces[3].pos = Vector2(3, 2)
#	black_pieces[4].pos = Vector2(4, 1)
#	black_pieces[5].pos = Vector2(4, 3)
#	black_pieces[6].pos = Vector2(5, 2)
#	black_pieces[7].pos = Vector2(6, 1)
#	black_pieces[8].pos = Vector2(6, 3)
#	black_pieces[9].pos = Vector2(7, 2)
#	black_pieces[10].pos = Vector2(8, 1)
#	black_pieces[11].pos = Vector2(8, 3)
#	set_process(true)
