extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var bridge = preload("res://tiles/TurningBridgeTile.tscn")
onready var myTween = get_node("Tween")
var LENGTH = 8
var BUILD_SPEED = 1
var NodeMap
var initPos
var initialDirection
var direction
var lastPos

func build_bridge():
	var firstPos = lastPos
	# Get tileTypes of adjacent nodes
	var adjNodes = NodeMap.get_adj_nodes(lastPos)
	if direction == NodeMap.EAST or direction == NodeMap.WEST:
		if adjNodes[direction].get_tileType() == 0:
			lastPos = lastPos + direction
		elif adjNodes[NodeMap.NORTH].get_tileType() == 0:
			lastPos = lastPos + NodeMap.NORTH
			direction = NodeMap.NORTH
		elif adjNodes[NodeMap.SOUTH].get_tileType() == 0:
			lastPos = lastPos + NodeMap.SOUTH
			direction = NodeMap.SOUTH
	elif direction == NodeMap.NORTH or direction == NodeMap.SOUTH:
		if adjNodes[direction].get_tileType() == 0:
			lastPos = lastPos + direction
	
	if (firstPos == lastPos):
		myTween.stop(self, "build_bridge")
		return
	
	NodeMap.placeTile(lastPos, NodeMap.TILES.TURNINGBRIDGETILE)

	
func play(anim, pos, orientation):
	if (anim == "build"):
		initialDirection = orientation
		direction = orientation
		lastPos = pos - direction
		for i in range(0,LENGTH):
			myTween.interpolate_callback(self, i*BUILD_SPEED, "build_bridge")
		myTween.start()

func init(nodeMapPath):
	NodeMap = nodeMapPath

func _ready():
	pass
	
