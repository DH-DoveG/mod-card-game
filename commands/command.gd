extends RefCounted
class_name Command

var _args: Variant = null
var _execute_state = false

func is_execute() -> bool:
	return _execute_state

func args(param: Variant) -> Command:
	_args = param
	return self

func execute():
	if not is_execute():
		return
	_execute_state = true
	return

func undo() -> void:
	pass
