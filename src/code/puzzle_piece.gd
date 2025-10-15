class_name PuzzlePiece
extends GridElement

var piece_value := 1

func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked on area!")

		# Optional: Check which button
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click!")
			piece_clicked.emit(grid_index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click!")

# Make this awaitable - returns the score after animation completes
func trigger_scoring() -> int:
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
