extends Node
class_name CoreInteractionApi

const _IN_OPTION_PLAYER_KEY := "_IN_OPT_PLAYER"

var _top_tips_map: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func player_option(key: bool):
	var scene = Utils.get_current_scene()
	if key:
		scene.add_in_option(_IN_OPTION_PLAYER_KEY)
	else:
		scene.remove_in_option(_IN_OPTION_PLAYER_KEY)

@rpc("any_peer", "call_remote", "reliable")
func show_select_dialog(config: Dictionary):
	var dialog = DialogUtils.show_select_item_dialog(config)
	var _res = await dialog.select_clicked # .20 应该在等待这个
	return _res

@rpc("any_peer", "call_remote", "reliable")
func show_select_card_dialog(config: Dictionary):
	var dialog = DialogUtils.show_select_card_dialog(config)
	var result = await dialog.select_clicked # .20 应该在等待这个
	return result

@rpc("any_peer", "call_remote", "reliable")
func show_confirm_dialog(config: Dictionary):
	var dialog = DialogUtils.show_custom_dialog(config)
	var result = await dialog.select_clicked # .20 应该在等待这个
	return result["option"]

@rpc("any_peer", "call_remote", "reliable")
func show_choose_areas(config: Dictionary):
	var scene = Utils.get_current_scene()
	var option = load("res://components/option/option_choose_area/option_choose_area.tscn").instantiate()
	scene.add_child(option)

	option.set_data(config)

	var res: Array = await option.finished
	if is_instance_valid(option):
		option.queue_free()
	return {
		"areas": res[0],
		"option": res[1]
	}

@rpc("any_peer", "call_local", "reliable")
func show_tab_dialog(config: Dictionary):
	var scene = Utils.get_current_scene()
	var dialog = load("res://components/dialog/tab_dialog/tab_dialog.tscn").instantiate()
	scene.add_child(dialog)
	dialog.set_value(config)
	var _res = await dialog.select_clicked # .20 应该在等待这个
	dialog.queue_free()
	return {
		"tab": _res[0],
		"item": _res[1],
		"value": _res[2],
	}

@rpc("any_peer", "call_local", "reliable")
func show_top_tips(_config: Dictionary):
	var id = _config.get("id", "")
	if id.is_empty(): return
	var skip_player_id = _config.get("skip_player_id", "")
	if not skip_player_id.is_empty():
		var battle: Battle = Utils.get_current_scene()
		if battle is Battle and battle.host_player_id == skip_player_id:
			return
	var text = _config.get("text", "请等待...")
	var top_tips = load("res://components/top_tips/top_tips.tscn").instantiate()
	Utils.get_current_scene().add_child(top_tips)
	top_tips.set_text(text)
	_top_tips_map[id] = top_tips

@rpc("any_peer", "call_local", "reliable")
func hide_top_tips(_config: Dictionary = {}):
	var id = _config.get("id", "")
	if not id.is_empty():
		if _top_tips_map.has(id):
			var top_tips = _top_tips_map[id]
			if is_instance_valid(top_tips):
				top_tips.queue_free()
			_top_tips_map.erase(id)
		return
	var top_tips = Utils.get_current_scene().get_node_or_null("TopTips")
	if top_tips:
		top_tips.queue_free()