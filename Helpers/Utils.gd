class_name Utils

static func flatten(two_dee_array: Array[Array]) -> Array:
	var result: Array = []
	for subarray in two_dee_array:
		result.append_array(subarray)
	return result

## Returns the key used to de/serialize the type in [method Utils.to_dict] and [method Utils.from_dict]
static func get_serializing_type_key() -> String:
	return str("_", Constants.PROP_TYPE_KEY, "_")
## Returns the key used to de/serialize the class name in [method Utils.to_dict] and [method Utils.from_dict]
static func get_serializing_class_name_key() -> String:
	return str("_", Constants.PROP_CLASS_NAME_KEY, "_")
## Returns the key used to de/serialize the value in [method Utils.to_dict] and [method Utils.from_dict]
static func get_serializing_value_key() -> String:
	return "_value_"
## Convert an object instance to a dictionary. Does not properly work with inner classes
## since they will not be able to be converted back using [method Utils.from_dict].
## Source: https://www.reddit.com/r/godot/comments/170r2pb/serializingdeserializing_custom_objects_fromto/
static func to_dict(obj: Variant) -> Dictionary:
	var result: Dictionary = {}
	if obj is Object:
		# if the object is of a built in type then only use the class name, or else use the path of the custom script
		var obj_class: String = obj.get_class()
		if !ClassDB.get_class_list().has(obj_class):
			obj_class = obj.get_script().get_path()

		result[get_serializing_type_key()] = TYPE_OBJECT
		result[get_serializing_class_name_key()] = obj_class  # This is a reference to the class/script type
		for property in obj.get_property_list():
			# print("Property name: ", property.name, " Usage: ", property.usage)
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE || property.usage & PROPERTY_USAGE_DEFAULT:
				result[property.name] = to_dict(obj.get(property.name))
				# var prop_value = obj.get(property.name)
				# if prop_value is Object:
				# 	result[property.name] = to_dict(prop_value)
				# else:
				# 	result[property.name] = prop_value
	else:
		result[get_serializing_type_key()] = typeof(obj) if obj != null else TYPE_NIL
		result[get_serializing_value_key()] = obj
	return result
## Create an object instance from a dictionary. If the type of the object was a custom class, then
## make sure the original script is in the same location as it was when [method Utils.to_dict]
## was called. This will not work for inner classes.
## Source: https://www.reddit.com/r/godot/comments/170r2pb/serializingdeserializing_custom_objects_fromto/
static func from_dict(data: Dictionary) -> Variant:
	if !data.has(get_serializing_type_key()):
		push_error("Could not find key '", get_serializing_type_key(), "' in dictionary")
		return null
	if data[get_serializing_type_key()] == TYPE_OBJECT:
		if !data.has(get_serializing_class_name_key()):
			push_error("Could not find key '", get_serializing_class_name_key(), "' in dictionary")
			return null
		# create instance either from built in class if it exists or else from custom class
		var obj_type: String = data[get_serializing_class_name_key()]
		var instance: Object
		if ClassDB.class_exists(obj_type):
			instance = ClassDB.instantiate(obj_type)
		else:
			instance = load(obj_type).new()
		# populate the properties of the instance
		for key in data.keys():
			var is_type: bool = key == get_serializing_type_key()
			var is_class_name: bool = key == get_serializing_class_name_key()
			if !is_type && !is_class_name:
				# WARNING: [method Object.set] sometimes would end the function without an error and without a return
				# if the value of the property is a serialized object then deserialize it, or else take it as it is
				instance.set(key, from_dict(data[key]))
				# if data[key] is Dictionary && data[key].has(get_serializing_class_name_key()):
				# 	instance.set(key, from_dict(data[key]))
				# else:
				# 	instance.set(key, data[key])
		return instance
	else:
		if !data.has(get_serializing_value_key()):
			push_error("Could not find key '", get_serializing_value_key(), "' in dictionary")
			return null
		return data[get_serializing_value_key()]

## Joins two paths and adds a forward slash in between if necessary
static func join_path(path: String, other: String) -> String:
	var joined_path: String
	if path.ends_with("/"):
		joined_path = str(path, other)
	else:
		joined_path = str(path, "/", other)
	return joined_path