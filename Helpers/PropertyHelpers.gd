class_name PropertyHelpers

## Creates a property with the given [param name] that would be a dropdown list of all the input actions found in [member InputMap.get_actions()]
static func create_input_map_enum_property(name: String, load_from_project_settings: bool = true) -> Dictionary:
	if load_from_project_settings:
		InputMap.load_from_project_settings()
	var actions: Array[StringName] = InputMap.get_actions()
	return create_enum_property(name, actions)
## Creates a property with the given [param name] that would be a dropdown list of all the [param keys]
static func create_enum_property(name: String, keys: Array) -> Dictionary:
	return {
		name = name,
		type = 2,
		hint = 2,
		hint_string = to_enum_hint_string(keys),
		usage = 69638
	}
## Creates the hint_string needed for a property of type enum using the provided [param keys]
static func to_enum_hint_string(keys: Array) -> String:
	var hint_string: String = ""
	for i in keys.size():
		hint_string = str(hint_string, keys[i], ":", i)
		if i < keys.size() - 1:
			hint_string = str(hint_string, ",")
	return hint_string
## Creates a property with the given [param name] that would be a toggle
static func create_toggle_property(name: String) -> Dictionary:
	return {
		name = name,
		type = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT
	}
## Creates a property with the given [param name] that would be a category
static func create_category_property(name: String) -> Dictionary:
	return {
		name = name,
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY
	}