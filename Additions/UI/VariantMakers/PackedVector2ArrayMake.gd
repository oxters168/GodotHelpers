@tool
extends AbstractVariantMake
class_name PackedVector2ArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedVector2Array = PackedVector2Array()
	return result