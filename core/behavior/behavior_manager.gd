extends RefCounted
class_name BehaviorManager

var behaviors = []

## 添加行为到组中
func add_behavior(behavior: Behavior):
	if Utils.get_current_scene().get("timepoint_manager"):
		Utils.get_current_scene().timepoint_manager.subscribe(behavior)
	behaviors.append(behavior)
