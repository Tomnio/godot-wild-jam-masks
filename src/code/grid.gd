class_name Grid
extends Node2D

@export var grid: Dictionary[Vector2i, GridElement] = {}

var empty_cell_scene := preload("res://scenes/empty_cell.tscn")

var inner_piece_size := 104 

func _ready() -> void:
	PieceMaker.grid = self
	place_starter_piece()
	pass



# ============================================================
# PIECES
# ============================================================
func place_piece(grid_pos: Vector2i, piece: GridElement) -> void:
	if grid_pos in grid and not is_instance_of(grid[grid_pos], EmptyCell):
		return
	
	# Remove the old empty cell if it exists
	if grid_pos in grid and is_instance_of(grid[grid_pos], EmptyCell):
		var old_cell = grid[grid_pos]
		old_cell.queue_free()
	
	add_to_grid(grid_pos, piece)
	create_connected_empty_cells(piece.grid_index)
	start_scoring()

func place_starter_piece() -> void:
	var piece := PieceMaker.create_piece()
	add_to_grid(Vector2i.ZERO, piece)
	create_connected_empty_cells(piece.grid_index)

func collect_scoring_pieces_in_order() -> Array[PuzzlePiece]:
	return get_puzzle_pieces()

func get_puzzle_pieces() -> Array[PuzzlePiece]:
	var returnage: Array[PuzzlePiece] = []
	for element in grid.values():
		if element is PuzzlePiece:
			returnage.append(element as PuzzlePiece)
	return returnage

# ============================================================
# EMPTY CELLS
# ============================================================
func place_empty_cell(grid_pos: Vector2i, cell: EmptyCell):
	add_to_grid(grid_pos, cell)


func create_connected_empty_cells(grid_pos: Vector2i) -> void:
	var adjacent_cells = get_adjacent_cells(grid_pos)
	for cell in adjacent_cells:
		create_empty_cell(cell)
	pass

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

# TODO
func get_connected_cells(grid_pos: Vector2i) -> Array:
	var adjacent_cells = []
	adjacent_cells.append(grid_pos + Vector2i.RIGHT)   # right
	adjacent_cells.append(grid_pos + Vector2i.LEFT)  # left
	adjacent_cells.append(grid_pos + Vector2i.DOWN)  # down
	adjacent_cells.append(grid_pos + Vector2i.UP)  # up
	return adjacent_cells

func add_to_grid(grid_pos: Vector2i, grid_element: GridElement) -> bool:
	if grid.has(grid_pos) and is_instance_of(grid[grid_pos], PuzzlePiece):
		return false
	grid[grid_pos] = grid_element
	grid_element.grid_index = grid_pos
	grid_element.position = Vector2(grid_pos) * inner_piece_size
	add_child(grid_element)
	
	# Connect to signal if it's a clickable piece
	if grid_element.has_signal("piece_clicked"):
		grid_element.piece_clicked.connect(_on_piece_clicked)
	
	return true

func _on_piece_clicked(at_position: Vector2i) -> void:
	var piece := PieceMaker.create_piece()
	place_piece(at_position, piece)

func start_scoring() -> void:
	Score.count_score(collect_scoring_pieces_in_order())
	pass
