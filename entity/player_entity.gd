extends Entity
class_name Player


var bt_agent_id = ""
var bt_table = null

var use_deck_config: Dictionary = {}
var player_name: String = ""
var id = null
var use_card_back = "DEFAULT_CARD_BACK" # 默认卡背资源ID
var player_avatar = "DEFAULT_AVATAR"

var round_timer_out_callback_rpc_id: int = 0
var round_timer_out_callback: String = ""
var round_timer_out = 120 # 轮次超时时间，单位秒

signal time_update(int)

@rpc("any_peer", "call_local", "reliable")
func set_timeout(timeout: int):
	round_timer_out = timeout
	time_update.emit(round_timer_out)
	#if round_timer_out == -1:
		#Utils.get_current_scene().rpc_awaiter.send_rpc(round_timer_out_callback_rpc_id, Utils.get_current_scene().callback_cache.call_cache.bind(round_timer_out_callback, name))


#func _on_timer_timeout() -> void:
	#var time = round_timer_out - timer.wait_time
	#rpc("set_timeout", time)

#
#func _ready() -> void:
	#add_to_group("player")


# func set_camp(_camp: String) -> void:
# 	camp = _camp

#
func set_time(_key: bool):
	pass
	#if key:
		#timer.start()
	#else:
		#timer.stop()


func set_info(param: Dictionary) -> void:
	id = param["uid"] # 玩家ID（唯一标识符，数字）
	player_name = param["name"]
	player_avatar = param["avatar"]
	#_build_agent(param["agent"])


#func _build_agent(agent_id):
	#return
	#if agent_id.is_empty():
		#return
	#bt_agent_id = agent_id
	#var f = GResourceManager.agent_resource[agent_id]
	#var _table = ModManager.do_mod_file(f).invoke()
	#bt_table = _table
	#var task = ba(_table)
	#var bt = BehaviorTree.new()
	#bt.set_root_task(task)
	#bt_player.behavior_tree = bt
#
#
#func ba(item: LuaTable) -> BTTask:
	#var task: BTTask = null
	#var type = item["type"]
	#var custom_name = item["custom_name"]
	#var children = item["children"]
	#if children is LuaTable:
		#children = children.to_array()
	#match type:
		#"Sequence":
			#task = BTSequence.new()
		#"Condition":
			#task = load("res://ai/tasks/mod_condition.gd").new()
			#task.action_method = item["method"]
		#"Selector":
			#task = BTSelector.new()
		#"RandomSelector":
			#task = BTRandomSelector.new()
		#"Action":
			#task = load("res://ai/tasks/mod_action.gd").new()
			#task.action_method = item["method"]
	#task.custom_name = custom_name
	#if children:
		#for child in children:
			#var ct = ba(child)
			#task.add_child(ct)
	#return task


func start_round() -> Variant:
	return null


func end_round() -> Variant:
	return null


func event_processing(_param) -> Variant:
	return null


func interaction_processing(_param) -> Variant:
	return null
