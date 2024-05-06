@tool
extends AbstractVariantMake
class_name PackedColorArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedColorArray = PackedColorArray()
	return result