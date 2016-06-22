
extends Node


var gl = preload("res://scripts/global.gd")
var board = preload("res://scripts/board_logic.gd")

const positive_infinity = 3.402823e+38
const negative_infinity = -2.802597e-45
var max_depth = 3


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


func generate_move_list(board):
	pass


func make_move(board, move):
	pass
