extends ColorRect


@onready var title := $Back/Title

var battle: Battle = null


func _ready() -> void:
	Utils.get_current_scene().event_manager.subscribe("SHOW_AREA_INFO_IN_PANEL", _event_bus_callable)
	pass # Replace with function body.


func _event_bus_callable(args) -> void:
	if typeof(args) == TYPE_DICTIONARY:
		if args["params"] is AreaEntity:
			show()
			var area: AreaEntity = args["params"]
			title.text = "（X%d,Y%d,Z%d）" % [area.x, area.y, area.z]
			$Info.clear()
			var info = battle.callback_cache.area_info_show_method.call(battle.host_player_id, area.name)
			$Info.append_text(info)
