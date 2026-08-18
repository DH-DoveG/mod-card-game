extends ColorRect


var is_expend := false
var sets = null
var current_show_set := ""

#var change_show := 0

var battle: Battle = null


#! 这里使用事件来实现
# battle.event_manager.emit("CardSetCreate", {
# 	set_name: card_set_id,
# 	config: config
# })
#
# battle.event_manager.emit("CardSetUpdate", {
# 	set_name: card_set_id,
# 	player_id: player_id,
# 	cards: battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id]
# })






func _ready() -> void:
	var v = $Scroll.get_v_scroll_bar()
	v.modulate.a = 0


func set_battle(_battle: Battle):
	battle = _battle
	battle.event_manager.subscribe("CardSetUpdate", _update)


# battle.event_manager.emit("CardSetUpdate", {
# 	set_name: card_set_id,
# 	player_id: player_id,
# 	cards: battle.battle_data_bind_list.card_set[card_set_id]["data"][player_id]
# })
func _update(args: Dictionary):
	if args["set_key"] != name:
		return
	for cid in args["sets"]["data"][args["player_id"]]:
		var ce = FindUtils.find_card(cid)
		for v in ce.get_view_3d():
			v.animate_free()
	update(args["sets"], args["set_key"], args["player_id"])


# { 
#     "config": {...}, 
#     "data": { "PlayerID1": ["CardID1"...], "PlayerID2": ["CardID2"...] } 
# }
func show_card_set(card_set, _default_title := ""):
	sets = card_set
	#$Title/Label.text = card_set["config"].get("show_text", _default_title)
	#_build_tab(sets["data"].keys())
	_build_tab()
	$Title/Label.text = card_set["config"].get("show_text", _default_title)
	#print("_def: ", _default_title, " --- ", name, " ||| ", card_set["config"].get("show_text", _default_title))


func update(card_set, _default_title := "", _player_id := ""):
	sets = card_set
	
	_build_tab()
	#$Title/Label.text = card_set["config"].get("show_text", _default_title)
	
	#print("_def: ", _default_title, " --- ", name, " ||| ", card_set["config"].get("show_text", _default_title), " | NOW SHOW: ", current_show_set)
	if _player_id != current_show_set and not _player_id.is_empty():
		return
	
	_build_card_view_2d(sets["data"][current_show_set])
	#把边框的颜色进行更改
	for t in $Tab.get_children():
		var camp = GApiManager.player_api.get_camp(t.name)
		if camp:
			t.get_node("Outline").border_color = camp.color


func _expend_reload_view():
	# 从 battle 获取最新数据
	_build_tab()
	#var cards = battle.battle_data_bind_list.card_set[str(name)]["data"][current_show_set]
	_build_reload_card_view_2d()
	pass


func _build_tab():
	
	var items = battle.battle_data_bind_list.card_set[str(name)]["data"].keys()
	
	for i in $Tab.get_children():
		if str(i.name) in items:
			items.erase(str(i.name))
	
	if items.is_empty():
		return
	
	# tab选中：#ababab
	# tab默认：#6e6e6e
	for pid in items:
		var pe := FindUtils.find_player(pid)
		var view = $Template/Tab.duplicate()
		view.name = pid
		$Tab.add_child(view)
		view.get_node("Icon").texture = GResourceManager.get_image_resoure(pe.player_avatar)
		var camp = GApiManager.player_api.get_camp(pid)
		if camp:
			view.get_node("Outline").border_color = camp.color
		view.pressed.connect(func():
			for t in $Tab.get_children():
				t.get_node("Color").color = Color("3d3d3d")
			view.get_node("Color").color = Color("ababab")
			current_show_set = pid
			#print("--> ", sets["data"], " | -->> ", current_show_set)
			_build_reload_card_view_2d()
		)
		view.show()
	
	if current_show_set.is_empty():
		#var t = $Tab.get_children()[0]
		#t.pressed.emit()
		var t = $Tab.get_child(0)
		t.get_node("Color").color = Color("ababab")
		current_show_set = str(t.name)


func _build_reload_card_view_2d():
	for i in $Scroll/Grid.get_children():
		i.queue_free()
	
	var cards = sets["data"][current_show_set]
	
	for cid in cards:
		var ce := FindUtils.find_card(cid)
		
		if sets["config"].has("system_hand_component") == false or sets["config"]["system_hand_component"] == false:
			for view in ce.get_view_2d():
				view.queue_free()
		
		var view: CardView2D = load("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		view.custom_minimum_size = Vector2(78, 109)
		view.set_card(ce)
		$Scroll/Grid.add_child(view)
	
	if sets["config"].get("sort"):
		# 排序卡片
		var views = $Scroll/Grid.get_children()
		views.sort_custom(func(a, b):
			return a.entity.name < b.entity.name
		)
		for i in range(views.size()):
			$Scroll/Grid.move_child(views[i], i)
	else:
		# 调整卡片顺序
		var i := 0
		for card in cards:
			$Scroll/Grid.move_child($Scroll/Grid.get_node(card), i)
			i += 1


#存在对于增量与替换的问题，以及非显示状态下的节点数量的问题需要解决
func _build_card_view_2d(cards: Array):
	# x78 | y109
	var now_cards = $Scroll/Grid.get_children()
	
	for i in range(now_cards.size() - 1, -1, -1):
		if now_cards[i].in_free:
			now_cards.remove_at(i)
	
	var save_cards = []
	var free_card_view_count = 0
	for card in now_cards:
		if str(card.name) in cards:
			save_cards.append(str(card.name))
		else:
			#card.queue_free()
			card.animate_free()
			free_card_view_count += 1
	var await_add_cards = []
	for card in cards:
		if card not in save_cards:
			await_add_cards.append(card)
			var ce := FindUtils.find_card(card)
			for view in ce.get_view_3d():
				view.animate_free()
	
	if not is_expend:
		#$Label.text = str(await_add_cards.size() - free_card_view_count)
		return
	
	if free_card_view_count == 0 and await_add_cards.size() == 0:
		if sets["config"].get("sort"):
			# 排序卡片
			var views = $Scroll/Grid.get_children()
			views.sort_custom(func(a, b):
				return a.entity.name < b.entity.name
			)
			for i in range(views.size()):
				$Scroll/Grid.move_child(views[i], i)
		return
	
	#for p in $Tab.get_children():
		#if p.name == current_show_set:
			#p.get_node("Label2").text = str(await_add_cards.size() - free_card_view_count)
		#pass
	#$Label.text = str(await_add_cards.size() - free_card_view_count)
		
	
	#if name == "Hand":
	for cid in await_add_cards:
		var ce := FindUtils.find_card(cid)
		
		#if sets["config"].has("system_hand_component") and sets["config"]["system_hand_component"]:
			#for view in ce.get_view_2d():
				#if view.get_parent().name != "Hand":
					#view.animate_free()
		#else:
			#for view in ce.get_view_2d():
				#view.animate_free()
		
		var view: CardView2D = load("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		view.custom_minimum_size = Vector2(78, 109)
		view.set_card(ce)
		$Scroll/Grid.add_child(view)
	
	if sets["config"].get("sort"):
		# 排序卡片
		var views = $Scroll/Grid.get_children()
		views.sort_custom(func(a, b):
			return a.entity.name < b.entity.name
		)
		for i in range(views.size()):
			$Scroll/Grid.move_child(views[i], i)
	else:
		# 调整卡片顺序
		var i := 0
		for card in cards:
			$Scroll/Grid.move_child($Scroll/Grid.get_node(card), i)
			i += 1


func _on_expend_pressed() -> void:
	is_expend = !is_expend
	var tween = get_tree().create_tween()
	if is_expend:
		size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
		tween.tween_property($Title/Icon, "rotation_degrees", 180, 0.25)
		$Tab.show()
		#_build_reload_card_view_2d()
		#_build_reload_card_view_2d(sets["data"][current_show_set])
		#_build_tab()
		_expend_reload_view()
	else:
		size_flags_vertical = Control.SIZE_FILL
		tween.tween_property($Title/Icon, "rotation", 0, 0.25)
		$Tab.hide()
		for view in $Scroll/Grid.get_children():
			view.queue_free()
