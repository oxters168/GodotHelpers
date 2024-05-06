@tool
extends AbstractVariantMake
class_name PackedVector3ArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedVector3Array = PackedVector3Array()
	return result