extends "res://tiles/scripts/BaseTile.gd"

func _ready():
	var parent = self.get_parent()
	get_node("Area2D").connect("mouse_enter",parent,"_select",[self])
	get_node("Area2D").connect("mouse_exit",parent,"_deselect",[self])
