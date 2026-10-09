extends Control

func add_player(player: Player) -> void:
		##blue.get_node("Color").color = color

		##red.get_node("Color").color = color

	var new_pa = load("res://components/player_avatar/player_avatar.tscn").instantiate()
	$VBox.add_child(new_pa)
	new_pa.set_player(player)

func update(p = null):
	for child in $VBox.get_children():
		if child.use_player == p:
			child.update()
			break
		elif p == null:
			child.update()
