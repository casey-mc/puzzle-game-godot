extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var tileType setget ,get_tileType

func get_tileType():
	return tileType

func _ready():
	tileType = 3
	
