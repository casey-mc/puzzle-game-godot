extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _fixed_process(delta):
	if is_colliding():
		var collider = get_collider()
		var col_pos = collider.get_collision_pos()
		print(collider)

func _ready():
	set_fixed_process(true)
