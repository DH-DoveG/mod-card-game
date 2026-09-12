extends RefCounted
class_name RuleManager

var rules: Dictionary[String, RuleEntry] = {}

func add_rule(rule_entry: RuleEntry, rule_name: String):
	rules[rule_name] = rule_entry

func exec_rule(rule_name: String, arg) -> Variant:
	# print("EXEC RULE|", rule_name, "|")
	if not rules.has(rule_name):
		return {}
	var rule = rules[rule_name]
	# print("EXEC RULE Entity|", rule, "|")
	rule.execute(arg)
	var res = await rule.execute_finished # 这里没有等到
	rule.later()
	return res
