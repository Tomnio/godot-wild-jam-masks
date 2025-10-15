extends Node

@export var total_round_score: int = 0
@export var current_score: int = 0

var scoreboard : RichTextLabel

@export var speed := 1
var is_scoring := false

# TODO
func count_score(pieces: Array[PuzzlePiece]) -> void:
	is_scoring = true
	
	for piece in pieces:
		await piece.trigger_scoring()
		current_score += piece.piece_value
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
