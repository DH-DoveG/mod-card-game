extends Object
class_name IDUtils


static var ids: PackedStringArray = []
# ID自增长记录 { prefix: count }
static var id_auto_increase: Dictionary[String, int] = {}


static func generate(prefix: String, value: String = "", length: int = 8) -> String:
	var id = ""
	if value.is_empty():
		if prefix not in id_auto_increase.keys():
			id_auto_increase[prefix] = 0
		id_auto_increase[prefix] += 1
		id = prefix + str(id_auto_increase[prefix]).lpad(length, "0")
		if id in ids:
			return generate(prefix, value, length)
		return id
	id = prefix + value.lpad(length, "0")
	ids.append(id)
	return id

static func clear(prefix: String) -> void:
	for i in range(ids.size() - 1, -1, -1):
		if ids[i].begins_with(prefix):
			ids.remove_at(i)
	id_auto_increase.erase(prefix)
