extends GridContainer

var grid : Array

@export var custom_minimum_grid_width := 3
@export var custom_minimum_grid_height := 3
const cell_scene = preload("res://scenes/cell.tscn")

var current_width:
	get:
		return columns
	set(value):
		columns = value
var current_height := 3


func _ready() -> void:
	columns = custom_minimum_grid_width
	pass

# ============================================================================
# Initializations
# ============================================================================
func init_game_grid() -> void:
	grid = []
	for x in range(current_width):
		print(x)
		var row = []
		for y in range(current_height):
			row.append(null)
		grid.append(row)
	#draw_grid()

func create_cells(amount: int) -> void:
	for i in range(amount):
		create_single_cell()
	pass

func create_single_cell() -> void:
	var new_cell = cell_scene.instantiate()
	add_child(new_cell)
	pass
