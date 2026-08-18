extends Animate


func _ready() -> void:
	finished.connect(stop)


func set_arg(_arg: Dictionary) -> void:
	pass


func play() -> void:
	pass


func stop() -> void:
	queue_free()


# 获取一个动画项目与时间列表
# 可用于调节
func get_list() -> Dictionary:
	return {}


# 获取耗时
func get_time() -> float:
	return 0.0
