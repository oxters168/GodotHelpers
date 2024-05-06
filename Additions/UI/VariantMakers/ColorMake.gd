@tool
extends AbstractVariantMake
class_name ColorMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Color
	if constructor_index == 1:
		result = Color(param_makes[0].get_value())
	elif constructor_index == 2:
		result = Color(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 3:
		result = Color(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value())
	elif constructor_index == 4:
		result = Color(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	else:
		result = Color()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("code", Enums.VariantType.TYPE_STRING)],
		[PropertyHelpers.create_property("code", Enums.VariantType.TYPE_STRING), PropertyHelpers.create_property("alpha", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("r", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("g", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("b", Enums.VariantType.TYPE_FLOAT)],
		[PropertyHelpers.create_property("r", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("g", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("b", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("a", Enums.VariantType.TYPE_FLOAT)]
	]