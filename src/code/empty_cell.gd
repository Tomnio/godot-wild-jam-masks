class_name EmptyCell
extends GridElement

signal piece_dropped_on_cell(piece: PuzzlePiece)


func _ready() -> void:
	add_to_group("empty_cells")
	piece_dropped_on_cell.connect(_on_piece_dropped)

func _on_piece_dropped(piece: PuzzlePiece) -> void:
	var grid = PieceMaker.grid
	if grid and grid.place_piece(grid_index, piece):
		# Successfully placed!
		pass
	else:
		# Invalid placement - return piece to deck
		piece.return_to_deck()


func check_for_piece_drop() -> void:
	if mouse_in and MouseBrain.node_being_dragged is PuzzlePiece:
		piece_dropped_on_cell.emit(MouseBrain.node_being_dragged)


func handle_mouse_input(event: InputEvent) -> void:
	if Score.is_scoring:
		return
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Empty cell clicked at:", grid_index)
			#piece_clicked.emit(grid_index)

var mouse_in = false
func _on_area_2d_mouse_entered() -> void:
	mouse_in = true

func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
