extends RefCounted
class_name Status

var code: String
var description: String

func data_init(_init: Variant): pass

func hook_callback(_name: String, _arg: Variant): pass

func start_callback(_entity_config): pass

func destroy_callback(_entity_config): pass
