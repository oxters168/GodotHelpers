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
			# switched to [method Object.set_deferred] since [method Object.set] would end
			# the function sometimes without an error and without a return
			instance.set_deferred(key, data[key])
	return instance
