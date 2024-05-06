@tool
extends AbstractVariantMake
class_name ProjectionMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Projection
	if constructor_index == 1:
		result = Projection(param_makes[0].get_value())
	elif constructor_index == 2:
		result = Projection(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	else:
		result = Projection()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("from", Enums.VariantType.TYPE_TRANSFORM3D)],
		[PropertyHelpers.create_property("x_axis", Enums.VariantType.TYPE_VECTOR4), PropertyHelpers.create_property("y_axis", Enums.VariantType.TYPE_VECTOR4), PropertyHelpers.create_property("z_axis", Enums.VariantType.TYPE_VECTOR4), PropertyHelpers.create_property("w_axis", Enums.VariantType.TYPE_VECTOR4)]
	]