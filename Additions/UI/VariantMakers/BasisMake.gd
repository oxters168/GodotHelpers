@tool
extends AbstractVariantMake
class_name BasisMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Basis
	if constructor_index == 1:
		result = Basis(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 2:
		result = Basis(param_makes[0].get_value())
	elif constructor_index == 3:
		result = Basis(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value())
	else:
		result = Basis()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("angle", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("from", Enums.VariantType.TYPE_QUATERNION)],
		[PropertyHelpers.create_property("x_axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("y_axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("z_axis", Enums.VariantType.TYPE_VECTOR3)]
	]