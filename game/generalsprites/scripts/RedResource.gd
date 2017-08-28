extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	var char = get_node("../Char")
	var colChild = get_node("Area2D")
	colChild.connect("body_enter", char, "_new_resource", [self])
