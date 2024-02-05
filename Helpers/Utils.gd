class_name Utils

func flatten(two_dee_array: Array[Array]) -> Array:
	var result: Array = []
	for subarray in two_dee_array:
		result.append_array(subarray)
	return result