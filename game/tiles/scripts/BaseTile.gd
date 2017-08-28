extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var tileType = 0 setget set_tileType,get_tileType
export var tileMapPos = Vector2() setget set_tileMapPos,get_tileMapPos

func get_tileType():
	return tileType

func set_tileType(arg):
	tileType = arg
	
func get_tileMapPos():
	return tileMapPos

func set_tileMapPos(arg):
	tileMapPos = arg

func _ready():
	pass