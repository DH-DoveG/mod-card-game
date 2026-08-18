extends Node
class_name CoreGameApi


@rpc("any_peer", "call_local", "reliable")
func create_camp(title, leader, units, orientation, color) -> void:
	var battle = Utils.get_current_scene()
	if battle is not Battle:
		assert(false, "create_camp: not in battle scene")
	#var camp = preload("res://core/camp/camp.tscn").instantiate()
	var id = IDUtils.generate("CAMP_")
	var camp := Camp.new()
	battle.camps[title] = camp
	#battle.get_node("CampMount").add_child(camp)
	#battle.add_child(camp)
	camp.id = id
	#camp.name = camp.id
	camp.title = title
	camp.leader = leader
	camp.units = units
	camp.orientation = orientation
	camp.color = Color(color)


@rpc("any_peer", "call_local", "reliable")
func game_end(wins, loses, dogfall) -> void:
	var tree = Utils.get_scene_tree()
	# 暂停游戏
	tree.paused = true
	# 隐藏所有弹窗
	for dialog in tree.get_nodes_in_group(&"Dialog"):
		dialog.hide()
	pass
	# 显示结果弹窗
	var scene = Utils.get_current_scene()
	var dialog = load("res://components/dialog/battle_over_panel/battle_over_panel.tscn").instantiate()
	scene.add_child(dialog)
	dialog.set_value({
		"wins": wins,
		"loses": loses,
		"dogfall": dogfall
	})
	# print("\nGAME API1: ", GApiManager.game_api, "\n")
	var _res = await dialog.select_clicked # .20 应该在等待这个
	# dialog.queue_free()
	# print("\nGAME API2: ", GApiManager.game_api, "\n")
	tree.paused = false
#
	#Utils.get_current_scene().event_manager.register = {}
	#Utils.get_current_scene() .clear()
	#Utils.get_current_scene().timepoint_manager.rr_meta = []
	#Utils.get_current_scene().timepoint_manager.rr_hook = {}
	#Utils.get_current_scene().timepoint_manager.timepoint_queue = null
	#Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method = Utils.get_current_scene().timepoint_manager.sort_timepoint_queue

	# print("\nGAME API3: ", GApiManager.game_api, "\n")

	# 切换场景到准备页面
	AsyncScene.new(
		"res://pages/pvp_ready/pvp_ready.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		scene
	) \
	.with_parameters(scene._play_meta_config) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()

@rpc("any_peer", "call_local", "reliable")
func set_global_variable(key: String, value: Variant) -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	battle.battle_global_data[key] = value

@rpc("any_peer", "call_remote", "reliable")
func remove_global_variable(key: String) -> bool:
	if key == "":
		return false
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return false
	var battle: Battle = scene
	battle.battle_global_data.erase(key)
	return true

@rpc("any_peer", "call_local", "reliable")
func set_angle_of_view(angle: String) -> void:
	var angle_v = Vector2.ZERO
	match angle:
		"DOWN":
			angle_v = Vector2i.DOWN
		"LEFT":
			angle_v = Vector2i.LEFT
		"UP":
			angle_v = Vector2i.UP
		"RIGHT":
			angle_v = Vector2i.RIGHT
	Utils.get_current_scene().set_angle_of_view(angle_v)

@rpc("any_peer", "call_local", "reliable")
func set_battle_ready_loading_state(state: bool) -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	battle.set_loading_page(state)
