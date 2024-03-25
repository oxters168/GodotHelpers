extends Resource
class_name BipedalMeasurements

# torso / height ratio = 0.818 - 0.530 = 0.288
# thigh / height ratio = 0.530 - 0.285 = 0.245
# shin / thigh ratio = (0.285 - 0.039) / (0.530 - 0.285) = 0.246 / 0.245 = 1.0041
# foot / thigh ratio = 0.039 / (0.530 - 0.285) = 0.039 / 0.245 = 0.1592
# Source: https://biology.stackexchange.com/questions/62839/what-is-the-ratio-of-head-to-waist-and-waist-to-floor-of-the-human-anatomy

## The total height of the ragdoll in meters
@export var ragdoll_height: float = 1.73
## The distance between limbs in meters
@export var joint_cushion: float = 0

## The ratio between the head radius and the ragdoll height
@export var head_radius_ratio: float = 0.055
## The ratio between the head height and the ragdoll height
@export var head_height_ratio: float = 0.130
## The ratio between the neck radius and the ragdoll height
@export var neck_radius_ratio: float = 0.02
## The ratio between the neck height and the ragdoll height
@export var neck_height_ratio: float = 0.05

## The ratio between the torso width and the ragdoll height
@export var torso_width_ratio: float = 0.245
## The ratio between the torso height and the ragdoll height
@export var torso_height_ratio: float = 0.288
## The ratio between the torso thickness and the ragdoll height
@export var torso_thickness_ratio: float = 0.1

## The ratio between the arm radius and the ragdoll height
@export var arm_radius_ratio: float = 0.04
## The ratio between the bicep length and the ragdoll height
@export var bicep_length_ratio: float = 0.186
## The ratio between the forearm length and the ragdoll height
@export var forearm_length_ratio: float = 0.146
## The ratio between the hand length and the ragdoll height
@export var hand_length_ratio: float = 0.108

## The ratio between the leg radius and the ragdoll height
@export var leg_radius_ratio: float = 0.04
## The ratio between the knee distance and the ragdoll height
@export var knee_distance_ratio: float = 0.191
## The ratio between the thigh height and the ragdoll height
@export var thigh_height_ratio: float = 0.245
## The ratio between the shin height and the ragdoll height
@export var shin_height_ratio: float = 0.245
## The ratio between the foot length and the ragdoll height
@export var foot_length_ratio: float = 0.12
## The ratio between the foot height and the ragdoll height
@export var foot_height_ratio: float = 0.039

func get_spine_size() -> Vector3:
	return Vector3(ragdoll_height * torso_width_ratio, ragdoll_height * torso_height_ratio / 3, ragdoll_height * torso_thickness_ratio)
func get_leg_radius() -> float:
	return ragdoll_height * leg_radius_ratio
func get_knee_distance() -> float:
	return ragdoll_height * knee_distance_ratio
func get_thigh_height() -> float:
	return ragdoll_height * thigh_height_ratio
func get_shin_height() -> float:
	return ragdoll_height * shin_height_ratio
func get_foot_size() -> Vector3:
	var leg_radius = get_leg_radius()
	return Vector3(leg_radius * 2, ragdoll_height * foot_height_ratio, ragdoll_height * foot_length_ratio)