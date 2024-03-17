## Angular constraint data
extends Resource
class_name AngularLimits3D

@export var lower_limit: Vector3
@export var upper_limit: Vector3
func _init(lower_limit_: Vector3, upper_limit_: Vector3):
	lower_limit = lower_limit_
	upper_limit = upper_limit_