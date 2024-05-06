@tool
extends AbstractVariantMake
class_name StringNameMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: StringName = StringName(param_makes[0].get_value())
	return result

func get_constructors() -> Array:
	return [
		[PropertyHelpers.create_property("from", Enums.VariantType.TYPE_STRING)],
	]