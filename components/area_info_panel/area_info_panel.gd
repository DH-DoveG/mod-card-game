extends ColorRect


@onready var title := $Back/Title


func _ready() -> void:
	Utils.get_current_scene().event_manager.subscribe("SHOW_AREA_INFO_IN_PANEL", _event_bus_callable)
	pass # Replace with function body.


func _event_bus_callable(args) -> void:
	if typeof(args) == TYPE_DICTIONARY:
		if args["params"] is AreaEntity:
			show()
			var area: AreaEntity = args["params"]
			title.text = "区域信息（X%d,Y%d,Z%d）" % [area.x, area.y, area.z]
