extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = get_popup() #"theme_override_font_sizes/font_size"
	popup.add_theme_font_size_override(&"font_size", 32)
	popup.add_theme_constant_override(&"font_separator_size", 16)
	popup.index_pressed.connect(func(index):
		if not Utils.is_battle_scene(): return
		var key = popup.get_item_text(index)
		var battle: Battle = Utils.get_current_scene()
		var content = battle.battle_data_bind_list.card_set[key]["data"]
		var scs = load("res://components/option/option_show_card_set/option_show_card_set.tscn").instantiate()
		Utils.get_current_scene().add_child(scs)
		scs.init_data(key, content)
	)
	update()


func update() -> void:
	if not Utils.is_battle_scene(): return
	var battle: Battle = Utils.get_current_scene()
	var keys = battle.battle_data_bind_list.card_set.keys()
	var popup = get_popup()
	popup.clear()
	for key in keys:
		popup.add_item(key)


func _on_button_down() -> void:
	update()
	pass # Replace with function body.
