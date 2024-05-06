@tool
extends AbstractVariantMake
class_name Transform3DMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Transform3D
	if constructor_index == 1:
		result = Transform3D(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 2:
		result = Transform3D(param_makes[0].get_value())
	elif constructor_index == 3:
		result = Transform3D(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	else:
		result = Transform3D()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("basis", Enums.VariantType.TYPE_BASIS), PropertyHelpers.create_property("origin", Enums.VariantType.TYPE_VECTOR3)],
		[PropertyHelpers.create_property("from", Enums.VariantType.TYPE_PROJECTION)],
		[PropertyHelpers.create_property("x_axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("y_axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("z_axis", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("origin", Enums.VariantType.TYPE_VECTOR3)]
	]