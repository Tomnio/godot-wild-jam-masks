class_name EmptyCell
extends GridElement

func handle_mouse_input(event: InputEvent) -> void:
	if Score.is_scoring:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Empty cell clicked at:", grid_index)
			piece_clicked.emit(grid_index)
