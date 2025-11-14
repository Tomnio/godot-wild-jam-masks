extends Node

@export var total_round_score: int = 0
@export var current_score: int = 0

var scoreboard : RichTextLabel

@export var speed := 1
var is_scoring := false



func count_score_from_piece(piece: PuzzlePiece) -> void:
	is_scoring = true
	
	# Trigger the clicked piece first and add its score
	await piece.trigger_piece()
	current_score += piece.piece_value
	
	# Get all connected pieces within range and trigger them
	var pieces_to_trigger = piece.get_connected_pieces_in_range(piece.trigger_range)
	for next_piece in pieces_to_trigger:
		await next_piece.trigger_piece()
		current_score += next_piece.piece_value
	
	update_score_visuals(current_score)
	is_scoring = false






func init_scoreboard(scoreboard_node: RichTextLabel) -> void:
	scoreboard = scoreboard_node
	update_score_visuals(current_score)
	pass



func update_score_visuals(score: int) -> void:
	if not scoreboard:
		return
	scoreboard.text = str(score)
	pass
