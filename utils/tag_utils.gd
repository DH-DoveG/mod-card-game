# 这是一个全局的
# 但是，如果是全局的，那应该如何管理单个对象的标签呢？
# 这需要每个对象都有一个专属的ID，类似于这样
# "Object ID": [ "Tag1", "Tag2" ]
# 这对于长期的对象或许比较有效，但是如果是短期的呢？移除时是否也需要从这里进行移除
# 所以说，或许可以通过编组的方法，每个对象添加一个Tag节点，这样管理器中的方法就可以作为静态方法调用
# 不过如果是添加编组的形式，形式只对Node及以下的有效，我需要想一想是否其他不是Node的也需要标签
extends Object
class_name TagUtils


# FIXME: 待修复
static func add_tag(id: String, tag: String) -> void:
	# if tags.has(id):
	# 	tags[id].append(tag)
	# else:
	# 	tags[id] = PackedStringArray([tag])
	pass


# FIXME: 待修复
static func remove_tag(id: String, tag: String) -> void:
	# if id.is_empty():
	# 	for key in tags.keys():
	# 		tags[key].erase(tag)
	# if tags.has(id):
	# 	tags[id].erase(tag)
	pass


# FIXME: 待修复
# Returns: { id: [ "eq_tag1", "eq_tag2" ] }
func find_all_tag(tag: String, strict: bool) -> Dictionary:
	# var result: Dictionary = {}
	# for key in tags.keys():
	# 	if find_once_tag(key, tag, strict):
	# 		result[key] = tags[key]
	# return result
	return {}


# FIXME: 待修复
# Returns: [ "eq_tag1", "eq_tag2" ]
func find_once_tag(id: String, tag: String, strict: bool) -> Array:
	# if id.is_empty():
	# 	return []
	# if strict:
	# 	var result = []
	# 	for item in tags[id]:
	# 		if item == tag:
	# 			result.append(item)
	# else:
	# 	var result = []
	# 	for item in tags[id]:
	# 		var split = item.split(".")
	# 		for sub_tag in split:
	# 			if sub_tag == tag:
	# 				result.append(item)
	# return []
	return []
