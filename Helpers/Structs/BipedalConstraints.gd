extends Resource
class_name BipedalConstraints

## The lower angular limits of the left ankle along each axis measured in degrees
@export var left_ankle_lower_limit: Vector3 = Vector3(-60, -15, -15)
## The upper angular limits of the left ankle along each axis measured in degrees
@export var left_ankle_upper_limit: Vector3 = Vector3(10, 15, 15)
## The lower angular limit of the left knee along its rotational axis measured in degrees
@export var left_knee_lower_limit: float = -80
## The upper angular limit of the left knee along its rotational axis measured in degrees
@export var left_knee_upper_limit: float = 0
## The lower angular limits of the left hip along each axis measured in degrees
@export var left_hip_lower_limit: Vector3 = Vector3(-10, -80, -15)
## The upper angular limits of the left hip along each axis measured in degrees
@export var left_hip_upper_limit: Vector3 = Vector3(170, 80, 45)


## The lower angular limits of the right ankle along each axis measured in degrees
@export var right_ankle_lower_limit: Vector3 = Vector3(-60, -15, -15)
## The upper angular limits of the right ankle along each axis measured in degrees
@export var right_ankle_upper_limit: Vector3 = Vector3(10, 15, 15)
## The lower angular limit of the right knee along its rotational axis measured in degrees
@export var right_knee_lower_limit: float = -80
## The upper angular limit of the right knee along its rotational axis measured in degrees
@export var right_knee_upper_limit: float = 0
## The lower angular limits of the right hip along each axis measured in degrees
@export var right_hip_lower_limit: Vector3 = Vector3(-10, -80, -45)
## The upper angular limits of the right hip along each axis measured in degrees
@export var right_hip_upper_limit: Vector3 = Vector3(170, 80, 15)


## The lower angular limits of the left wrist along each axis measured in degrees
@export var left_wrist_lower_limit: Vector3 = Vector3(-90, 0, -15)
## The upper angular limits of the left wrist along each axis measured in degrees
@export var left_wrist_upper_limit: Vector3 = Vector3(90, 0, 15)
## The lower angular limit of the left elbow along its rotational axis measured in degrees
@export var left_elbow_lower_limit: float = -90
## The upper angular limit of the left elbow along its rotational axis measured in degrees
@export var left_elbow_upper_limit: float = 0
## The lower angular limits of the left clavicle along each axis measured in degrees
@export var left_clavicle_lower_limit: Vector3 = Vector3(-90, -80, -90)
## The upper angular limits of the left clavicle along each axis measured in degrees
@export var left_clavicle_upper_limit: Vector3 = Vector3(90, 135, 90)


## The lower angular limits of the right wrist along each axis measured in degrees
@export var right_wrist_lower_limit: Vector3 = Vector3(-90, 0, -15)
## The upper angular limits of the right wrist along each axis measured in degrees
@export var right_wrist_upper_limit: Vector3 = Vector3(90, 0, 15)
## The lower angular limit of the right elbow along its rotational axis measured in degrees
@export var right_elbow_lower_limit: float = -90
## The upper angular limit of the right elbow along its rotational axis measured in degrees
@export var right_elbow_upper_limit: float = 0
## The lower angular limits of the right clavicle along each axis measured in degrees
@export var right_clavicle_lower_limit: Vector3 = Vector3(-90, -135, -90)
## The upper angular limits of the right clavicle along each axis measured in degrees
@export var right_clavicle_upper_limit: Vector3 = Vector3(90, 80, 90)


## The lower angular limit of the first spine joint along its rotational axis measured in degrees
@export var spine_1_lower_limit: float = -20
## The upper angular limit of the first spine joint along its rotational axis measured in degrees
@export var spine_1_upper_limit: float = 20
## The lower angular limit of the second spine joint along its rotational axis measured in degrees
@export var spine_2_lower_limit: float = -20
## The upper angular limit of the second spine joint along its rotational axis measured in degrees
@export var spine_2_upper_limit: float = 20
## The lower angular limits of the neck along each axis measured in degrees
@export var neck_lower_limit: Vector3 = Vector3(-80, -90, -60)
## The upper angular limits of the right neck along each axis measured in degrees
@export var neck_upper_limit: Vector3 = Vector3(80, 90, 60)
## The lower angular limits of the head along each axis measured in degrees
@export var head_lower_limit: Vector3 = Vector3(-15, 0, -15)
## The upper angular limits of the right head along each axis measured in degrees
@export var head_upper_limit: Vector3 = Vector3(15, 0, 15)