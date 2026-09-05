extends RefCounted
class_name Behavior

class BehaviorTrigger extends RefCounted:
	var origin := "" # 作为行为源的 玩家ID、区域ID、卡片ID
	var trigger := "" # 玩家ID、区域ID、卡片ID
	var code := "" # 行为的Code
	func to_dict():
		return {
			"origin": origin,
			"code": code,
			"trigger": trigger
		}

var data
var template = ""

func get_info() -> Dictionary:
	return {
		"name": "",
		"type": "",
		"description": "",
		"code": ""
	}

# 初始化数据
func init_data(init):
	data = init

# 支付行为代价
func cost(_bt: BehaviorTrigger, _arg): pass

# 发动行为
func launch(_bt: BehaviorTrigger, _arg) -> void: pass

# 执行行为
func execute(_bt: BehaviorTrigger, _arg): pass

# 检查是否可支付代价
func check_cost(_bt: BehaviorTrigger, _arg) -> bool:
	await Utils.get_scene_tree().process_frame
	return true

# 检查是否可发动行为
func check_launch(_bt: BehaviorTrigger, _args) -> bool:
	await Utils.get_scene_tree().process_frame
	return true

# 事件的回调
func hook_callback(_bt: BehaviorTrigger, _name: String, _arg: Variant) -> Variant: return null
