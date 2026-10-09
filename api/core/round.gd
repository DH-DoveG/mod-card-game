extends Node
class_name CoreRoundApi

@rpc("any_peer", "call_local", "reliable")
func set_current(round_num: int, player_id: String) -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	if player_id.is_empty():
		return
	if round_num != -1:
		battle.round_num = round_num
	if not player_id.is_empty():
		battle.current_round_player = player_id

	scene.get_node("UI/PlayerPanel").update(null)

@rpc("any_peer", "call_local", "reliable")
func set_action_sequence(list, index) -> void:
	# LogUtils.info(str("[CORE] 1 SET ACTION SEQUENCE: ", list, " -- ", index))
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	# LogUtils.info(str("[CORE] 2 SET ACTION SEQUENCE: ", list, " -- ", index))
	if list:
		battle.round_action_sequence = list
	if index:
		battle.round_index = index % battle.round_action_sequence.size()

const _IN_OPTION_ROUND_KEY := "_IN_OPT_ROUND"

@rpc("any_peer", "call_local", "reliable")
func start_round(player_id: String) -> void:
	var battle: Battle = get_tree().current_scene
	if battle.host_player_id == player_id:
		battle.remove_in_option(_IN_OPTION_ROUND_KEY)
	else:
		battle.add_in_option(_IN_OPTION_ROUND_KEY)