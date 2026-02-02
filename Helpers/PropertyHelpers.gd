class_name PropertyHelpers

## Creates a property with the given [param name] that would be a dropdown list of all the input actions found in [member InputMap.get_actions()]
static func create_input_map_enum_property(name: String, load_from_project_settings: bool = true) -> Dictionary:
	if load_from_project_settings:
		InputMap.load_from_project_settings()
	var actions: Array[StringName] = InputMap.get_actions()
	return create_enum_property(name, actions)

## Creates the hint_string needed for a property of type enum using the provided [param values]
static func to_enum_hint_string(values: Array) -> String:
	var hint_string: String = ""
	for i in values.size():
		hint_string = str(hint_string, values[i], ":", i)
		if i < values.size() - 1:
			hint_string = str(hint_string, ",")
	return hint_string

## Creates a property with the given [param name] that would be a dropdown list of all the [param values]
static func create_enum_property(name: StringName, values: Array) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_INT, "", PROPERTY_HINT_ENUM, to_enum_hint_string(values), PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_CLASS_IS_ENUM)
## Creates a property with the given [param name] that would be a toggle field for a [bool]
static func create_toggle_property(name: StringName) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_BOOL)
## Creates a property with the given [param name] that would be a [float] input field
static func create_float_property(name: StringName) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_FLOAT)
## Create a property with the given [param name] that would be a [Vector3] input field
static func create_vector3_property(name: StringName) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_VECTOR3)
## Creates a property with the given [param name] that would be a category
static func create_category_property(name: StringName) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_NIL, "", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_CATEGORY)
## Creates a property with the given [param name] that would be a scene object
static func create_scene_object_property(name: StringName, clazz_name: StringName) -> Dictionary:
	return create_property(name, Enums.VariantType.TYPE_OBJECT, clazz_name, PROPERTY_HINT_NODE_TYPE)

## [param name] is the property's name, as a String;
## [param type] is the property's type;
## [param clazz_name] is an empty StringName, unless the property is TYPE_OBJECT and it inherits from a class;
## [param hint] is how the property is meant to be edited (see PropertyHint);
## [param hint_string] depends on the hint (see PropertyHint);
## [param usage] is a combination of PropertyUsageFlags.
static func create_property(name: StringName, type: Enums.VariantType, clazz_name: StringName = "", hint: int = PROPERTY_HINT_NONE, hint_string: String = "", usage: int = PROPERTY_USAGE_DEFAULT) -> Dictionary:
	return {
		"name" = name,
		"class_name" = clazz_name,
		"type" = type,
		"hint" = hint,
		"hint_string" = hint_string,
		"usage" = usage,
	}

## Turns an array of properties into a string that looks like the parameters of a function
static func to_func_signature(properties: Array) -> String:
	var params: String = properties.map(func(param):
		return str(type_string(param.type), " ", param.name)
	).reduce(func(accum, current):
		if accum.is_empty():
			return current
		else:
			return str(accum, ", ", current)
	, "")
	return str("(", params, ")")
