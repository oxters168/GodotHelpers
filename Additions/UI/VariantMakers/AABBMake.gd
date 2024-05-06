@tool
extends AbstractVariantMake
class_name AABBMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: AABB = AABB(param_makes[0].get_value(), param_makes[1].get_value())
	return result

func get_constructors() -> Array:
	return [
		[PropertyHelpers.create_property("position", Enums.VariantType.TYPE_VECTOR3), PropertyHelpers.create_property("size", Enums.VariantType.TYPE_VECTOR3)]
	]