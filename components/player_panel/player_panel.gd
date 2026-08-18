extends Control


#@onready var blue = $Blue
#@onready var red = $Red


func add_player(player: Player) -> void:
# func set_player(player: Player, direction: Vector2i, color: Color) -> void:
	#if direction == Vector2i.DOWN:
		#blue.set_player(player)
		##blue.get_node("Color").color = color
		#blue.self_modulate = color
	#elif direction == Vector2i.UP:
		#red.set_player(player)
		##red.get_node("Color").color = color
		#red.self_modulate = color
	var new_pa = load("res://components/player_avatar/player_avatar.tscn").instantiate()
	$VBox.add_child(new_pa)
	new_pa.set_player(player)
	#if $VBox.get_child_count() > 2: $ALL.show()
	#else: $ALL.hide()


func update(p = null):
	for child in $VBox.get_children():
		if child.use_player == p:
			child.update()
			break
		elif p == null:
			child.update()
