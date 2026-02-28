extends Resource
class_name VehicleData

@export_category("Occupancy")
## Whether this can occupy others
@export_flags("FORCE_DRIVEN_CHARACTER:1", "CAR:2", "SPEED_BOAT:4", "HELICOPTER:8") var can_occupy: int = 0
## How many others can occupy this
@export var occupant_seats: int = 0
## The exit spots for each seat, must equal [member occupant_seats] or 1 if all seats lead to the same spot.
## The values are in local space.
@export var exit_spots: Array[Vector3] = []

@export_category("Towability")
## Whether this can tow others
@export_flags("FORCE_DRIVEN_CHARACTER:1", "CAR:2", "SPEED_BOAT:4", "HELICOPTER:8") var can_tow: int = 0
## Spots this can tow others from
@export var tow_give_spots: Array[Vector3] = []
## Spots this can be towed from
@export var tow_receive_spots: Array[Vector3] = []