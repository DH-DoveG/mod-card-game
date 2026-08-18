extends Node3D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in range(-2, 3):
		for j in range(-2, 3):
			$GridMap.set_cell_item(Vector3i(i, 0, j), 0)
			pass
	
	#$GridMap.set_cell_item(Vector3i(-4, 0, -2), 0)
	pass # Replace with function body.
