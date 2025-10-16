extends Node

var grid : Grid

var piece_scene := preload("res://scenes/puzzle_piece.tscn")
var empty_cell_scene := preload("res://scenes/empty_cell.tscn")


func create_piece() -> PuzzlePiece:
	var piece := piece_scene.instantiate()
	piece.generate_connections()
	piece.update_piece_shape()
	return piece

func create_starter_piece() -> PuzzlePiece:
	var piece : PuzzlePiece = piece_scene.instantiate()
	
	# Create a 4-way connection with random tabs/slots
	var directions_dict := {}
	
	# Randomly assign "t" (tab) or "s" (slot) to each direction
	for direction in ["u", "r", "d", "l"]:
		directions_dict[direction] = "t" if randf() < 0.5 else "s"
	
	piece.directions = directions_dict
	piece.is_part_of_grid = true
	piece.update_piece_shape()
	
	return piece


func create_empty_cell() -> EmptyCell:
	var empty_cell := empty_cell_scene.instantiate()
	return empty_cell
