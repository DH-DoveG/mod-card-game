extends PopupMenu

var behaviors = []
var card_entity: CardEntity

#
func _ready() -> void:
	add_theme_font_size_override(&"font_size", 32)
	add_theme_constant_override(&"font_separator_size", 16)
	#pass


func show_menu(pos, _behaviors, _entity: CardEntity) -> bool:
	behaviors = _behaviors
	card_entity = _entity
	var scene = get_tree().current_scene
	if scene is not Battle:
		return false
	var battle: Battle = scene
	if battle.in_option:
		return false
	# 直接默认挂载的是卡片
	var mount_name: String = _entity.name
	var can = false
	if mount_name.begins_with("CARD_"):
		for k in battle.battle_data_bind_list.player_bind_cards_of_controller:
			if mount_name in battle.battle_data_bind_list.player_bind_cards_of_controller[k]:
				if k == battle.host_player_id:
					can = true
	if not can: return false
	clear()
	var id = 0
	
	var bt = Behavior.BehaviorTrigger.new()
	bt.trigger = battle.host_player_id
	bt.origin = _entity.name
	
	for bname: String in behaviors:
		var behavior: Behavior = scene.behaviors[bname]
		bt.code = bname
		var info = behavior.get_info()
		var check_launch = await behavior.check_launch(bt, {})
		var check_cost = await behavior.check_cost(bt, {})
		if check_launch and check_cost:
			add_item("【" + info["type"] + "】" + info["name"], id)
		id += 1
	if item_count == 0:
		queue_free()
		return false
	popup()
	var _pos = pos
	_pos.x -= float(size.x) / 2
	_pos.y -= (size.y + 78)
	position = _pos
	return true


#func _on_popup_menu_popup_hide() -> void:
	# FIXME: 先随便写写


func _on_id_pressed(id: int) -> void:
	var scene = get_tree().current_scene
	if scene is not Battle:
		return
	var battle: Battle = scene
	# 判断当前行动的是否是主机玩家
	# ？可能有人要问：鸽子鸽子，那那种在对方回合也可以发动的效果怎么办呀？
	# ！因为不是主机玩家的回合所以说主机玩家也没有第一时间的发动权，
	# ！也就是说不能够在对方什么也没做的时候像自己回合一样发效果，需要时点的
	if battle.host_player_id != battle.current_round_player:
		return
	if battle.in_option:
		return
	var behavior_entry: Behavior = battle.behaviors[behaviors[id]]
	#var check_launch = await behavior_entry.check_launch()
	#var check_cost = await behavior_entry.check_cost()
	#if !check_launch or !check_cost:
		#return
	var bt = Behavior.BehaviorTrigger.new()
	bt.code = behavior_entry.get_info()["code"]
	bt.trigger = battle.host_player_id
	bt.origin = card_entity.name
	behavior_entry.launch(bt, {
		trigger = (Utils.get_current_scene() as Battle).host_player_id
	})


func _on_popup_hide() -> void:
	#if get_parent()
	#get_parent().get_node("../Area3D/CollisionShape3D").disabled = false
	pass # Replace with function body.
