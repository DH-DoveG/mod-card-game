extends RefCounted
class_name RuleManager

var rules: Dictionary[String, RuleEntry] = {}
var behavior_launch_rule: String = ""

func add_rule(rule_entry: RuleEntry, rule_name: String):
	rules[rule_name] = rule_entry

func exec_rule(rule_name: String, arg) -> Variant:
	if not rules.has(rule_name):
		return {}
	var rule = rules[rule_name]
	rule.execute(arg)
	var res = await rule.execute_finished
	if typeof(res) == TYPE_ARRAY:
		await rule.later(res[1])
		return res[0]
	else:
		await rule.later()
	return res

func set_behavior_launch_rule(rule_name: String):
	behavior_launch_rule = rule_name
