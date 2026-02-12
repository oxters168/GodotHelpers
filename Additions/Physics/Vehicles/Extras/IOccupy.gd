extends Resource
class_name IOccupy

## Whether this can occupy others
@export var can_occupy: bool = false
## How many others can occupy this
@export var occupant_seats: int = 0