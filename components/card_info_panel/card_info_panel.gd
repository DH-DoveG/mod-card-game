extends ColorRect


@onready var title: Label = $Back/Title

var battle: Battle = null

var current_show_card: CardEntity = null


func _ready() -> void:
	Utils.get_current_scene().event_manager.subscribe("SHOW_CARD_INFO_IN_PANEL", _event_bus_callable)


func _event_bus_callable(args) -> void:
	if typeof(args) == TYPE_DICTIONARY:
		if args["params"] is CardEntity:
			if current_show_card == args["params"]:
				return
			show()
			set_card_show(args["params"])


func set_card_show(card: CardEntity) -> void:
	show_card_base(card)
	current_show_card = card
	$Info.clear()
	var info = battle.callback_cache.card_info_show_method.call(battle.host_player_id, card.name)
	$Info.append_text(info)


func show_card_base(card: CardEntity) -> void:
	title.text = card.card_name


#func _on_close_pressed() -> void:
	#queue_free()


# --------------属性---------------
# LV：2 | AP： 2 | DP： 2 | SP： 2 | ATTACK：1 | MOVE：1
# --------------特征---------------
# Tag1，Tag2，Tag3，Tag4，Tag5，Tag6，Tag7，Tag8
# --------------效果---------------
# 【启动】：文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述，文本描述。
# 【瞬发】
# --------------行为---------------
# 【降临】：xxx
# 【】
