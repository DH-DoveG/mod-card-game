extends RefCounted
class_name EventManager


class EventListener extends RefCounted:
	var id: String = ""
	var callback: Callable


var register: Dictionary = {}


func subscribe(event_name: StringName, callback: Callable) -> String:
	var id = IDUtils.generate("EVENT_LISTENER_")
	var listener = EventListener.new()
	listener.id = id
	listener.callback = callback
	if not register.has(event_name):
		register[event_name] = []
	register[event_name].append(listener)
	return id


func unsubscribe(event_name: StringName, id: String):
	if register.has(event_name):
		register[event_name].erase(id)


func emit(event_name: StringName, args: Dictionary):
	if register.has(event_name):
		for listener in register[event_name]:
			if is_instance_valid(listener): listener.callback.call(args)
			else: register[event_name].erase(listener)
