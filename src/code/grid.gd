class_name Grid
extends Node2D

@export var grid: Dictionary[Vector2i, GridElement] = {}

var empty_cell_scene := preload("res://scenes/empty_cell.tscn")

var inner_piece_size := 104 
var deck : Deck :
	get:
		if not deck or not is_instance_valid(deck) or not deck.is_inside_tree():
			# Try to find the Deck in the scene tree
			var deck_node = get_tree().get_first_node_in_group("deck")
			if deck_node and is_instance_of(deck_node, Deck):
				deck = deck_node
			else:
				push_warning("Deck node not found in scene tree")
				return null
		return deck

func _ready() -> void:
	PieceMaker.grid = self
	place_starter_piece()
	pass



# ============================================================
# PIECES
# ============================================================
func place_piece(grid_pos: Vector2i, piece: GridElement) -> bool:
	if grid_pos in grid and not is_instance_of(grid[grid_pos], EmptyCell):
		return false
	
	# Validate that the piece can connect to at least one neighbor
	if is_instance_of(piece, PuzzlePiece):
		if not can_place_piece_at(grid_pos, piece as PuzzlePiece):
			print("Cannot place piece at", grid_pos, "- no valid connections")
			return false
	
	# Remove the old empty cell if it exists
	if grid_pos in grid and is_instance_of(grid[grid_pos], EmptyCell):
		var old_cell = grid[grid_pos]
		old_cell.queue_free()
	
	add_to_grid(grid_pos, piece)
	connect_pieces(grid_pos, piece)
	Score.count_score_from_piece(piece)
	create_connected_empty_cells(piece.grid_index)
	
	deck.spawn_piece()
	
	return true

func can_place_piece_at(grid_pos: Vector2i, piece: PuzzlePiece) -> bool:
	var has_at_least_one_connection = false
	
	# Check all four directions
	for direction in piece.directions:
		var connection_type = piece.directions[direction]
		
		var neighbor_pos: Vector2i
		var required_opposite_direction: String
		
		match direction:
			"u":
				neighbor_pos = grid_pos + Vector2i.UP
				required_opposite_direction = "d"
			"r":
				neighbor_pos = grid_pos + Vector2i.RIGHT
				required_opposite_direction = "l"
			"d":
				neighbor_pos = grid_pos + Vector2i.DOWN
				required_opposite_direction = "u"
			"l":
				neighbor_pos = grid_pos + Vector2i.LEFT
				required_opposite_direction = "r"
			_:
				continue
		
		# Check if neighbor exists
		if grid.has(neighbor_pos):
			var neighbor = grid[neighbor_pos]
			
			# If neighbor is a PuzzlePiece, validate the connection
			if is_instance_of(neighbor, PuzzlePiece):
				var neighbor_piece: PuzzlePiece = neighbor as PuzzlePiece
				
				# Get the neighbor's connection type in the opposite direction
				if required_opposite_direction in neighbor_piece.directions:
					var neighbor_connection_type = neighbor_piece.directions[required_opposite_direction]
					
					# Check if this piece's side is an edge
					if connection_type == "e":
						# Edge cannot connect to a piece
						return false
					
					# Check if neighbor's side is an edge
					if neighbor_connection_type == "e":
						# Piece cannot connect to neighbor's edge
						return false
					
					# Valid connections: tab-to-slot or slot-to-tab only
					if (connection_type == "t" and neighbor_connection_type == "s") or \
					   (connection_type == "s" and neighbor_connection_type == "t"):
						has_at_least_one_connection = true
					else:
						# Invalid connection (tab-to-tab or slot-to-slot)
						return false
	
	# Must have at least one valid connection to place
	return has_at_least_one_connection

func connect_pieces(grid_pos: Vector2i, piece: PuzzlePiece) -> void:
	for direction in piece.directions:
		var connection_type = piece.directions[direction]
		
		# Skip edges - they can't connect
		if connection_type == "e":
			continue
		
		var neighbor_pos: Vector2i
		var required_opposite_direction: String
		
		match direction:
			"u":
				neighbor_pos = grid_pos + Vector2i.UP
				required_opposite_direction = "d"
			"r":
				neighbor_pos = grid_pos + Vector2i.RIGHT
				required_opposite_direction = "l"
			"d":
				neighbor_pos = grid_pos + Vector2i.DOWN
				required_opposite_direction = "u"
			"l":
				neighbor_pos = grid_pos + Vector2i.LEFT
				required_opposite_direction = "r"
			_:
				continue
		
		# Check if neighbor exists and is a PuzzlePiece
		if grid.has(neighbor_pos):
			var neighbor = grid[neighbor_pos]
			if is_instance_of(neighbor, PuzzlePiece):
				var neighbor_piece: PuzzlePiece = neighbor as PuzzlePiece
				
				# Check if neighbor has the opposite direction
				if required_opposite_direction in neighbor_piece.directions:
					var neighbor_connection_type = neighbor_piece.directions[required_opposite_direction]
					
					# Only connect if it's a valid tab-to-slot or slot-to-tab connection
					if (connection_type == "t" and neighbor_connection_type == "s") or \
					   (connection_type == "s" and neighbor_connection_type == "t"):
						# Make bidirectional connection
						piece.connected_pieces.append(neighbor_piece)
						if piece not in neighbor_piece.connected_pieces:
							neighbor_piece.connected_pieces.append(piece)

func place_starter_piece() -> void:
	var piece := PieceMaker.create_starter_piece()
	add_to_grid(Vector2i.ZERO, piece)
	create_connected_empty_cells(piece.grid_index)


# ============================================================
# EMPTY CELLS
# ============================================================
func place_empty_cell(grid_pos: Vector2i, cell: EmptyCell):
	add_to_grid(grid_pos, cell)


func create_connected_empty_cells(grid_pos: Vector2i) -> void:
	# Only create empty cells where the piece at grid_pos has connection directions
	if not grid.has(grid_pos):
		return
	
	var piece = grid[grid_pos]
	if not is_instance_of(piece, PuzzlePiece):
		return
	
	var puzzle_piece: PuzzlePiece = piece as PuzzlePiece
	
	# Only create empty cells in directions where the piece has tabs or slots (not edges)
	for direction in puzzle_piece.directions:
		var connection_type = puzzle_piece.directions[direction]
		
		# Skip if this direction has an edge - edges can't connect
		if connection_type == "e":
			continue
		
		var neighbor_pos: Vector2i
		
		match direction:
			"u":
				neighbor_pos = grid_pos + Vector2i.UP
			"r":
				neighbor_pos = grid_pos + Vector2i.RIGHT
			"d":
				neighbor_pos = grid_pos + Vector2i.DOWN
			"l":
				neighbor_pos = grid_pos + Vector2i.LEFT
			_:
				continue
		
		create_empty_cell(neighbor_pos)

func create_adjacent_empty_cells(grid_pos: Vector2i) -> void:
	var adjacent_cells = get_adjacent_cells(grid_pos)
	for cell in adjacent_cells:
		create_empty_cell(cell)
	pass

func create_empty_cell(grid_pos: Vector2i) -> void:
	var empty_cell = PieceMaker.create_empty_cell()
	if grid.has(grid_pos):
		return
	place_empty_cell(grid_pos, empty_cell)
	pass

# ============================================================
# HELPERS
# ============================================================
func get_adjacent_cells(grid_pos: Vector2i) -> Array:
	var adjacent_cells = []
	adjacent_cells.append(grid_pos + Vector2i.RIGHT)   # right
	adjacent_cells.append(grid_pos + Vector2i.LEFT)  # left
	adjacent_cells.append(grid_pos + Vector2i.DOWN)  # down
	adjacent_cells.append(grid_pos + Vector2i.UP)  # up
	return adjacent_cells
#
## TODO
#func get_connected_pieces(directions: Array[String]) -> Array:
	#var connected_pieces = []
	#if "u" in directions:
		#connected_pieces.append(grid_pos + Vector2i.RIGHT)   # right
	#connected_pieces.append(grid_pos + Vector2i.LEFT)  # left
	#connected_pieces.append(grid_pos + Vector2i.DOWN)  # down
	#connected_pieces.append(grid_pos + Vector2i.UP)  # up
	#return connected_pieces

func add_to_grid(grid_pos: Vector2i, grid_element: GridElement) -> bool:
	if grid.has(grid_pos) and is_instance_of(grid[grid_pos], PuzzlePiece):
		return false
	grid[grid_pos] = grid_element
	grid_element.grid_index = grid_pos
	grid_element.position = Vector2(grid_pos) * inner_piece_size
	
	if grid_element.is_inside_tree():
		grid_element.get_parent().remove_child(grid_element)
	grid_element.is_part_of_grid = true
	add_child(grid_element)
	
	# Connect to signal if it's a clickable piece
	if grid_element.has_signal("piece_clicked"):
		grid_element.piece_clicked.connect(_on_piece_clicked)
	
	return true

func _on_piece_clicked(at_position: Vector2i) -> void:
	var piece := PieceMaker.create_piece()
	place_piece(at_position, piece)
