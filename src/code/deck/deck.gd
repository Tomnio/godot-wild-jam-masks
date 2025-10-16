class_name Deck
extends Node2D

var deck : Array[PuzzlePiece] = []
var current_piece : PuzzlePiece = null

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

func spawn_piece(exclude_piece: PuzzlePiece = null) -> void:
	if deck.size() <= 0:
		return
	
	# If we only have the excluded piece, just take it
	if exclude_piece and deck.size() == 1 and deck[0] == exclude_piece:
		var piece = deck[0]
		deck.remove_at(0)
		add_child(piece)
		current_piece = piece
		return
	
	# Pick a random piece that isn't the excluded one
	var index = randi() % deck.size()
	var piece = deck[index]
	
	# If we picked the excluded piece and there are others, pick again
	while piece == exclude_piece and deck.size() > 1:
		index = randi() % deck.size()
		piece = deck[index]
	
	piece.position = Vector2.ZERO
	deck.remove_at(index)
	add_child(piece)
	current_piece = piece

func despawn_piece(piece: PuzzlePiece) -> void:
	if piece.get_parent() == self:
		remove_child(piece)
	deck.append(piece)

func redraw_piece() -> void:
	var previous_piece = current_piece
	if current_piece and is_instance_valid(current_piece):
		despawn_piece(current_piece)
		current_piece = null
	
	# Spawn a new piece, excluding the previous one
	spawn_piece(previous_piece)


func _on_discard_button_button_down() -> void:
	redraw_piece()
