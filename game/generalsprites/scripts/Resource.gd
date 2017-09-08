extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var recAmount = 0
# Either equals Bridge0, TurningBridge, or RandomBridge
# Probably should make this array of bridgetypes an autoload singleton
export var recType = "Bridge0"

func _ready():
	get_node("Timer").start()

func _on_Area2D_body_enter( body ):
	if body.get_name() == "Char":
		body.incr_res(recType, recAmount)
		recAmount = 0

func _on_Timer_timeout():
	recAmount = recAmount + 1
