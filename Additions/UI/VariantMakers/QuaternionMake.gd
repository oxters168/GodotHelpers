@tool
extends AbstractVariantMake
class_name QuaternionMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Quaternion
	if constructor_index == 1:
		result = Quaternion(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 2:
		result = Quaternion(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 3:
		result = Quaternion(param_makes[0].get_value())
	elif constructor_index == 4:
		result = Quaternion(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	else:
		result = Quaternion()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("arc_from", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("arc_to", Enums.VariantType.TYPE_VECTOR3)],
		[PropertyHelpers.create_property("axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("angle", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("from", Enums.VariantType.TYPE_BASIS)],
		[PropertyHelpers.create_property("x", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("y", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("z", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("w", Enums.VariantType.TYPE_FLOAT)]
	]
