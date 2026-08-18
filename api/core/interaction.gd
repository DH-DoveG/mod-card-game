extends Node
class_name CoreInteractionApi


@rpc("any_peer", "call_local", "reliable")
func player_option(key: bool):
	var scene = Utils.get_current_scene()
	scene.in_option = key


@rpc("any_peer", "call_remote", "reliable")
func show_select_dialog(config: Dictionary):
	var dialog = DialogUtils.show_select_item_dialog(config)
	var _res = await dialog.select_clicked # .20 应该在等待这个
	return _res


@rpc("any_peer", "call_remote", "reliable")
func show_select_card_dialog(config: Dictionary):
	var dialog = DialogUtils.show_select_item_dialog(config)
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
	#scene.move_child(option, 1)
	option.set_data(config)
	# print("show_choose_areas config: ", config)
	var res: Array = await option.finished
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
	# print("_RES: ", _res)
	return {
		"tab": _res[0],
		"item": _res[1],
		"value": _res[2],
	}


@rpc("any_peer", "call_local", "reliable")
func show_top_tips(config: Dictionary):
	var top_tips = load("res://components/top_tips/top_tips.tscn").instantiate()
	Utils.get_current_scene().add_child(top_tips)
	top_tips.set_data(config)


@rpc("any_peer", "call_local", "reliable")
func hide_top_tips():
	var top_tips = Utils.get_current_scene().get_node("TopTips")
	if top_tips:
		top_tips.queue_free()
