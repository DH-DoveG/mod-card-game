extends ColorRect


var status = false
var data: CardEntity

signal change_status(d: CardEntity, state)


func set_card(card: CardEntity):
	data = card
	$Image.texture = GResourceManager.get_image_resoure(card.image)
	$CardName.text = card.card_name
	$Tags.text = " | ".join(card.tags)
	var value_text = []
	for vkey in card.value_manager:
		var v: Value = card.value_manager[vkey]
		if v.config and v.config.show_enable:
			value_text.append(v.nick + "：" + str(v.value))
	$Values.text = " | ".join(value_text)


func switch_btn_icon():
	if status:
		$Btn.texture_normal = load("res://addons/material_icons_importer/icons/indeterminateCheckBox.png")
		color = Color("#000000")
	else:
		$Btn.texture_normal = load("res://addons/material_icons_importer/icons/addBox.png")
		color = Color("#00000028")


func _on_btn_pressed() -> void:
	status = not status
	switch_btn_icon()
	change_status.emit(data, status)
