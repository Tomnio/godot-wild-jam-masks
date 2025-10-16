class_name Deck
extends Node2D

var deck : Array[PuzzlePiece] = []

# TODO maybe add seed instead
func _ready() -> void:
	randomize()
	for i in range(50):
		generate_new_piece()
	spawn_piece()

func generate_new_piece() -> void:
	var piece := PieceMaker.create_piece()
	deck.append(piece)
	pass

func spawn_piece() -> void:
	if deck.size() <= 0:
		return
	var index = randi() % deck.size()
	var piece = deck[index]
	deck.remove_at(index)
	add_child(piece)

	pass
