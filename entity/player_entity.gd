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

func set_time(_key: bool):
	pass

func set_info(param: Dictionary) -> void:
	id = param["uid"] # 玩家ID（唯一标识符，数字）
	player_name = param["name"]
	player_avatar = param["avatar"]

func start_round() -> Variant:
	return null

func end_round() -> Variant:
	return null

func event_processing(_param) -> Variant:
	return null

func interaction_processing(_param) -> Variant:
	return null
