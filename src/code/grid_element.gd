class_name GridElement
extends Node2D

signal piece_clicked(at_position: Vector2i)

var is_part_of_grid = false
var grid_index : Vector2i

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	handle_mouse_input(event)

func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked on area!")

		# Optional: Check which button
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click!")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click!")
