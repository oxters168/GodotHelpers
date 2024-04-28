class_name Utils

static func flatten(two_dee_array: Array[Array]) -> Array:
	var result: Array = []
	for subarray in two_dee_array:
		result.append_array(subarray)
	return result

## Convert an object instance to a dictionary. Does not properly work with inner classes
## since they will not be able to be converted back using [method FaggSettings.obj_from_dict].
## Source: https://www.reddit.com/r/godot/comments/170r2pb/serializingdeserializing_custom_objects_fromto/
static func obj_to_dict(obj: Object) -> Dictionary:
	var result: Dictionary = {
		"_type": obj.get_script().get_path()  # This is a reference to the class/script type.
	}
	for property in obj.get_property_list():
		#print("Property name: ", property.name, " Usage: ", property.usage)
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			result[property.name] = obj.get(property.name)
	return result
## Create an object instance from a dictionary. If the type of the object was a custom class, then
## make sure the original script is in the same location as it was when [method FaggSettings.obj_to_dict]
## was called. This will not work for inner classes.
## Source: https://www.reddit.com/r/godot/comments/170r2pb/serializingdeserializing_custom_objects_fromto/
static func obj_from_dict(data: Dictionary) -> Object:
	if !data.has("_type"):
		push_error("Could not find key '_type' in dictionary")
		return null
	var instance = load(data["_type"]).new()
	for key in data.keys():
		if key != "_type":
			# [method Object.set] sometimes would end the function without an error and without a return.
			# Switching to [method Object.set_deferred] stopped that issue, but then the returned object
			# does not contain the correct values.
			instance.set(key, data[key])
	return instance

## Joins two paths and adds a forward slash in between if necessary
static func join_path(path: String, other: String) -> String:
	var joined_path: String
	if path.ends_with("/"):
		joined_path = str(path, other)
	else:
		joined_path = str(path, "/", other)
	return joined_path