extends ColorRect

@onready var title: Label = $Back/Title

var battle: Battle = null

var current_show_card: CardEntity = null

var _locked_card: CardEntity = null

func _ready() -> void:
	$Info.get_v_scroll_bar().visible = false


func connect_event():
	Utils.get_current_scene().event_manager.subscribe("SHOW_CARD_INFO_IN_PANEL", _event_bus_callable)
	Utils.get_current_scene().event_manager.subscribe("LOCK_CARD_INFO", _on_lock_card_info)
	Utils.get_current_scene().event_manager.subscribe("UNLOCK_CARD_INFO", _on_unlock_card_info)


func _on_lock_card_info(args) -> void:
	if typeof(args) == TYPE_DICTIONARY and args.get("card") is CardEntity:
		_locked_card = args["card"]
		set_card_show(_locked_card)
		$Back/Lock.show()

func _on_unlock_card_info(_args) -> void:
	_locked_card = null
	$Back/Lock.hide()

func _event_bus_callable(args) -> void:
	if typeof(args) == TYPE_DICTIONARY:
		if args["params"] is CardEntity:
			if _locked_card and args["params"] != _locked_card:
				return
			if current_show_card == args["params"]:
				return
			var entity: CardEntity = args["params"]
			var cpi = battle.battle_data_bind_list.card_public_information[entity.name]
			if (battle.host_player_id not in cpi) and ("PUBLIC" not in cpi):
				return
			set_card_show(args["params"])

func set_card_show(card: CardEntity) -> void:
	show_card_base(card)
	current_show_card = card
	$Info.clear()
	var info = battle.callback_cache.card_info_show_method.call(battle.host_player_id, card.name)
	$Info.append_text(info)

func show_card_base(card: CardEntity) -> void:
	title.text = card.card_name
