extends Resource
class_name IOccupy

## Whether this can occupy others
@export_flags("FORCE_DRIVEN_CHARACTER:1", "CAR:2", "SPEED_BOAT:4", "HELICOPTER:8") var can_occupy: int = 0
## How many others can occupy this
@export var occupant_seats: int = 0
## The exit spots for each seat, must equal [member occupant_seats] or 1 if all seats lead to the same spot.
## The values are in local space.
@export var exit_spots: Array[Vector3] = []