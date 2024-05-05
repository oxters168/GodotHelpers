@tool
extends AbstractVariantMake
class_name PlaneMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Plane
	if constructor_index == 1:
		result = Plane(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	elif constructor_index == 2:
		result = Plane(param_makes[0].get_value())
	elif constructor_index == 3:
		result = Plane(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 4:
		result = Plane(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 5:
		result = Plane(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value())
	else:
		result = Plane()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("a", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("b", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("c", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("d", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("normal", Enums.VariantType.TYPE_VECTOR3)],
		[PropertyHelpers.create_property("normal", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("d", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("normal", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("point", Enums.VariantType.TYPE_VECTOR3)],
		[PropertyHelpers.create_property("point1", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("point2", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("point3", Enums.VariantType.TYPE_VECTOR3)]
	]
