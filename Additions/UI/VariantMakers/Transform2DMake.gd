@tool
extends AbstractVariantMake
class_name Transform2DMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Transform2D
	if constructor_index == 1:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 2:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	elif constructor_index == 3:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value())
	else:
		result = Transform2D()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("rotation", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("position", Enums.VariantType.TYPE_VECTOR2)],
		[PropertyHelpers.create_property("rotation", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("scale", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("skew", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("position", Enums.VariantType.TYPE_VECTOR2)],
		[PropertyHelpers.create_property("x_axis", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("y_axis", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("origin", Enums.VariantType.TYPE_VECTOR2)]
	]
