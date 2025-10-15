class_name PuzzlePiece
extends GridElement

@export var trigger_range := 3
@export var piece_value := 1

@export var directions := ["u", "r", "d"]
var connected_pieces : Array[PuzzlePiece]

func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked on area!")

		# Optional: Check which button
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click!")
			piece_clicked.emit(grid_index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click!")

func get_connected_pieces_in_range(search_range: int) -> Array[PuzzlePiece]:
	var pieces_in_range: Array[PuzzlePiece] = []
	
	if search_range <= 0:
		return pieces_in_range
	
	# BFS: Use a queue to explore layer by layer
	var queue: Array = []  # Array of {piece: PuzzlePiece, depth: int}
	var visited: Array[PuzzlePiece] = [self]  # Mark self as visited to exclude it
	
	# Start with direct connections at depth 1
	for piece in connected_pieces:
		if piece != self:  # Extra safety check
			queue.append({"piece": piece, "depth": 1})
			visited.append(piece)
			pieces_in_range.append(piece)
	
	# Process queue breadth-first
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_piece: PuzzlePiece = current["piece"]
		var current_depth: int = current["depth"]
		
		# Only explore further if we haven't reached max range
		if current_depth < search_range:
			for neighbor in current_piece.connected_pieces:
				if neighbor not in visited:
					visited.append(neighbor)
					pieces_in_range.append(neighbor)
					queue.append({"piece": neighbor, "depth": current_depth + 1})
	
	return pieces_in_range


# Make this awaitable - returns the score after animation completes
func trigger_piece() -> int:
	await play_trigger_animation()
	return piece_value

func play_trigger_animation() -> void:
	var tween = create_tween()
	tween.set_speed_scale(Score.speed)
	tween.set_parallel(true)
	
	# Scale pulse: grow then shrink back
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Flash white briefly
	var original_modulate = modulate
	tween.tween_property(self, "modulate", Color.WHITE, 0.05)
	tween.chain().tween_property(self, "modulate", original_modulate, 0.15)
	
	# Wait for animation to finish
	await tween.finished
