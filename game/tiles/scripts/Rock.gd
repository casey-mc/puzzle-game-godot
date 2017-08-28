extends "res://tiles/scripts/BaseTile.gd"

# Example rock properties are minerals per tick or resource type etc
var owned = false setget set_owned, get_owned


func get_owned():
	return owned
	
func set_owned(arg):
	owned = arg
	if (owned == true):
		set_modulate(Color(.04,.9,.88))
	else:
		set_modulate(Color(0,0,0))
		