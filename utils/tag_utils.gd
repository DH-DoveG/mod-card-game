extends Object
class_name TagUtils

static var _tag_map: Dictionary = {}

static func _match_tag(mapped_tag: String, search_tag: String, strict: bool) -> bool:
	if strict:
		return mapped_tag == search_tag
	var parts = mapped_tag.split(".")
	var search_parts = search_tag.split(".")
	if search_parts.size() > 1:
		return mapped_tag == search_tag
	return parts[parts.size() - 1] == search_tag

static func add_tag(id: String, tag: String) -> void:
	if not _tag_map.has(id):
		_tag_map[id] = []
	if tag not in _tag_map[id]:
		_tag_map[id].append(tag)

static func remove_tag(id: String, tag: String) -> void:
	if not _tag_map.has(id):
		return
	_tag_map[id].erase(tag)
	if _tag_map[id].is_empty():
		_tag_map.erase(id)

func find_all_tag(tag: String, strict: bool) -> Dictionary:
	var result: Dictionary = {}
	for id in _tag_map:
		var matches: Array = []
		for t in _tag_map[id]:
			if _match_tag(t, tag, strict):
				matches.append(t)
		if not matches.is_empty():
			result[id] = matches
	return result

func find_once_tag(id: String, tag: String, strict: bool) -> Array:
	if not _tag_map.has(id):
		return []
	var result: Array = []
	for t in _tag_map[id]:
		if _match_tag(t, tag, strict):
			result.append(t)
	return result