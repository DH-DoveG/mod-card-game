extends SelectItemDialog
class_name SelectCardDialog

@onready var cip = $Dialog/CardInfoPanel

var _current_selected_card_id: String = ""


func _ready() -> void:
	super()
	var battle = Utils.get_current_scene()
	if battle is Battle:
		cip.battle = battle
	else:
		cip.queue_free()


func _exit_tree() -> void:
	super()


func _list_item_pressed(btn: ColorRect, param: Dictionary) -> void:
	super(btn, param)
	var value = param.get("value", "")
	if typeof(value) == TYPE_STRING and value.begins_with("CARD_"):
		_current_selected_card_id = value
		_update_card_info(value)
	else:
		_current_selected_card_id = ""


func _update_card_info(card_id: String) -> void:
	pass
	if cip:
		if not cip.visible: cip.show()
		var card: CardEntity = FindUtils.find_card(card_id)
		cip._event_bus_callable({
			"params": card
		})


func _find_card_area_name(card_id: String) -> String:
	var battle = Utils.get_current_scene()
	if battle is not Battle:
		return ""

	var bind_list: DataStruct.BattleBindDataStruct = battle.battle_data_bind_list

	for _set_name in bind_list.card_set:
		var set_data = bind_list.card_set[_set_name]["data"]
		for pid in set_data:
			if card_id in set_data[pid]:
				return str(_set_name)

	for area_id in bind_list.area_bind_cards:
		if card_id in bind_list.area_bind_cards[area_id]:
			return "场上-" + area_id

	return ""
