extends CanvasLayer
class_name OptionBase


# 2026-01-13
# TODO: 应当找到一个办法规避当前状态下因为点击一些东西触发效果等内容
# 方案1：给battle一个属性，根据这个属性来控制，behaviorItem 与 回合阶段按钮（等互动按钮【可能会触发其他事件的】）
# 采用方案1

@onready var side = $Side

var is_hidden = false
var battle: Battle = null


signal finished # 完成时发出的信号


func set_data(_param) -> void:
	pass


#region 内置方法

func _enter_tree() -> void:
	var scene = Utils.get_current_scene()
	if not is_instance_valid(scene):
		return
	if scene is not Battle:
		return
	
	battle = scene
	#battle.ui.hide()


func _exit_tree() -> void:
	if battle:
		battle.ui.show()


#endregion


func _on_close_pressed() -> void:
	finished.emit()


func _on_confirmed_pressed() -> void:
	finished.emit()
