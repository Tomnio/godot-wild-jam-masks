extends Node

var grid : Grid

var piece_scene := preload("res://scenes/puzzle_piece.tscn")
var empty_cell_scene := preload("res://scenes/empty_cell.tscn")


func create_piece() -> PuzzlePiece:
	var piece := piece_scene.instantiate()
	return piece

func create_empty_cell() -> EmptyCell:
	var empty_cell := empty_cell_scene.instantiate()
	return empty_cell
