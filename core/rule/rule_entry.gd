extends RefCounted
class_name RuleEntry


# 规则 execute 完成时发送的信号
signal execute_finished


func execute(_data):
	await Utils.get_scene_tree().process_frame
	execute_finished.emit(null)


func later(): pass
