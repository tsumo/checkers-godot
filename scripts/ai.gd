
extends Node


var gl = preload("res://scripts/global.gd")
var board = preload("res://scripts/board_logic.gd")

const positive_infinity = 3.402823e+38
const negative_infinity = -2.802597e-45
var max_depth = 3

var all_pieces = get_tree().get_nodes_in_group("pieces_grp")
var black_pieces = get_tree().get_nodes_in_group("b")
var white_pieces = get_tree().get_nodes_in_group("w")


func _ready():
	pass


func eval_pos_recursive(depth, board, sign_factor):
	if depth == max_depth:
		return eval_pos_static(board)
	var move_list = generate_move_list(board)
	var value = negative_infinity
	var best_move
	for move in move_list:
		var new_board = make_move(board, move)
		var new_value = sign_factor * eval_pos_recursive(depth+1, new_board, -sign_factor)
		if new_value > value:
			value = new_value
			best_move = move
	return best_move


func eval_pos_static(board):
	pass


# Move list is stored in a dictionary with piece node name
# as keys and a list of moves as values
# [piece1 (move1, move2)
#  piece2 (move1, move2, move3)]
# Moves a stored as a list
# move = (from, to, capture_flag)
func generate_move_list(board):
	var moves = {}
	for piece in all_pieces:
		moves[piece.get_name()] = []
		if piece.has_normal_moves():
			pass


func make_move(board, move):
	pass


func get_piece_node_by_pos(pos):
	for piece in get_tree().get_nodes_in_group("pieces_grp"):
		if board_nd.world_to_map(piece.pos) == pos:
			return piece
	return false
