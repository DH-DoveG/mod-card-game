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
		var listeners: Array = register[event_name]
		for i in range(listeners.size() - 1, -1, -1):
			if listeners[i].id == id:
				listeners.remove_at(i)

func emit(event_name: StringName, ...args):
	if register.has(event_name):
		var listeners: Array = register[event_name]
		for listener in listeners.duplicate():
			if is_instance_valid(listener): listener.callback.callv(args)
			else: listeners.erase(listener)
