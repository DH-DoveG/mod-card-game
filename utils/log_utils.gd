extends Object
class_name LogUtils

static func info(_msg: String) -> void:
	pass

static func warn(msg: String) -> void:
	push_warning(msg)

static func error(msg: String) -> void:
	push_error(msg)
