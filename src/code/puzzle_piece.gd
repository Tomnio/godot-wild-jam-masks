class_name PuzzlePiece
extends GridElement

@export var trigger_range := 3
@export var piece_value := 1

var piece_size = Vector2(160, 160)

# t tabs s slots and e edges
@export var directions := {
	"u": "t",
	"d": "s",
	"r": "e",
	"l": "t"
	}
@export var number_of_connections := 2
var connected_pieces : Array[PuzzlePiece]


func _ready() -> void:
	original_position = global_position

func _process(delta: float) -> void:
	if not is_part_of_grid:
		drag_logic(delta)

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

func generate_connections() -> void:
	# Generate all connections randomly first
	for dir in directions:
		directions[dir] = generate_tabs_and_slots()
	
	# Check if we have at least one tab or slot
	var has_connection = false
	for dir in directions:
		if directions[dir] in ["t", "s"]:
			has_connection = true
			break
	
	# If all edges, force at least one random direction to be a tab or slot
	if not has_connection:
		var random_dir = directions.keys().pick_random()
		directions[random_dir] = ["t", "s"].pick_random()
	
	print(directions)
	pass

func generate_tabs_and_slots() -> String:
	return ["t", "s", "e"].pick_random()

func update_piece_shape() -> void:
	for dir in ["u", "r", "d", "l"]:
		match dir:
			"u":
				if directions["u"] == "t":
					add_sprite_to_mask("puzzleteil_top_tab.png")
				elif directions["u"] == "e":
					add_sprite_to_mask("puzzleteil_top_edge.png")
			"d":
				if directions["d"] == "t":
					add_sprite_to_mask("puzzleteil_bottom_tab.png")
				elif directions["d"] == "e":
					add_sprite_to_mask("puzzleteil_bottom_edge.png")
			"r":
				if directions["r"] == "t":
					add_sprite_to_mask("puzzleteil_right_tab.png")
				elif directions["r"] == "e":
					add_sprite_to_mask("puzzleteil_right_edge.png")
			"l":
				if directions["l"] == "t":
					add_sprite_to_mask("puzzleteil_left_tab.png")
				elif directions["l"] == "e":
					add_sprite_to_mask("puzzleteil_left_edge.png")
		pass
	pass

func add_sprite_to_mask(path: String) -> void:
	var base_mask_path = "res://assets/images/puzzle_piece_mask/"
	var sprite = Sprite2D.new()
	sprite.texture = load(base_mask_path + path)
	sprite.centered = false
	$TabAndSlotSprites.add_child(sprite)
	pass




# ============================================================
# DRAG N DROP
# ============================================================

var mouse_in := false
var is_dragging := false
func _on_area_2d_mouse_entered() -> void:
	mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false

var original_position
func drag_logic(delta: float) -> void:
	if (mouse_in or is_dragging) and (MouseBrain.node_being_dragged == null or MouseBrain.node_being_dragged == self):
		if Input.is_action_pressed("click"):
			if not is_dragging:
				original_position = global_position
			global_position = lerp(global_position, get_global_mouse_position() - (piece_size/2), 22.0*delta)
			is_dragging = true
			MouseBrain.node_being_dragged = self
		else:
			if is_dragging:
				# Just notify that we stopped dragging
				# EmptyCells will handle the placement check
				get_tree().call_group("empty_cells", "check_for_piece_drop")
			is_dragging = false
			if MouseBrain.node_being_dragged == self:
				MouseBrain.node_being_dragged = null
	pass

func return_to_deck() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.2).set_ease(Tween.EASE_OUT)
