extends Node2D

onready var bridge = preload("res://tiles/Bridge.tscn")
onready var myTween = get_node("Tween")
var outlineBridge
var NodeMap
var initPos
var index = 0
var LENGTH = 5
var BUILD_SPEED = 1
var orientation = Vector2(0,-1)
var lastPos

# TODO: Has no validation. Do we want it to be unable to build unless it has LENGTH amount of free tiles?

func build_bridge():
	NodeMap.placeTile(lastPos, NodeMap.TILES.BRIDGE)
	if (NodeMap.get_adj_node(lastPos,NodeMap.NORTH).get_tileType() == 0):
		lastPos = lastPos + NodeMap.NORTH
	else:
		return

#func bridge_translate():
#	var tempPos = outlineBridge.get_pos()+Vector2(0,-20)
#	outlineBridge.set_pos(tempPos)
	
#func get_next_pos(lastPos):
#	#uses last_pos to calculate new pos
#	#Check then up
#	if NodeMap.returnNode_by_mappos(lastPos+orientation).get_tileType() == NodeMap.TILES.SEA:
#		return lastPos + orientation
#	return "error"

func play(anim, pos):
#	if (anim == "outline"):
#		outlineBridge = bridge.instance()
#		outlineBridge.set_opacity(.5)
#		add_child(outlineBridge)
	if (anim == "build"):
		var direction = NodeMap.NORTH
		lastPos = pos
		for i in range(0,LENGTH):
			myTween.interpolate_callback(self, i*BUILD_SPEED, "build_bridge")
		myTween.start()
	
#func stop(anim):
#	if animPlayer.is_playing() and animPlayer.get_current_animation() == anim:
#		animPlayer.stop()

func init(nodeMapPath):
	NodeMap = nodeMapPath
	

func _ready():
	pass
	# Reset status of node
#	for child in get_children():
#		if not child.get_groups().has("persistent"):
#			child.queue_free()