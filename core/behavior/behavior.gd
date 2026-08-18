extends RefCounted
class_name Behavior


var data
var template = ""
var name := ""

#func _ready() -> void:
	#add_to_group("behavior")


# 获取描述信息
# 要求的数据结构：
# {"name": String, "type": String, "description": String}
func get_info() -> Dictionary:
	return {
		"name": "",
		"type": "",
		"description": ""
	}


# 初始化数据
func init_data(init): data = init


# 支付行为代价
func cost(): pass


# 发动行为
func launch(_arg) -> void: pass


# 执行行为
func execute(_arg): pass


# 检查是否可支付代价
func check_cost() -> bool:
	await Utils.get_scene_tree().process_frame
	return true


# 检查是否可发动行为
func check_launch(_args = {}) -> bool: 
	await Utils.get_scene_tree().process_frame
	return true


# 检查是否可执行行为
func check_execute() -> bool: return true


# 事件的回调
func hook_callback(_arg: Variant) -> Variant: return null
