extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var bridge = preload("res://tiles/TurningBridgeTile.tscn")
onready var animPlayer = get_node("AnimationPlayer")
var LENGTH = 8
var BUILD_SPEED = 1
var NodeMap
var initPos
var keys = []
var orientation = Vector2(-1,0)

func build_bridge(pos):
	print("Placing tile at ", pos)
	NodeMap.placeTile(pos, NodeMap.TILES.TURNINGBRIDGETILE)
	
func get_next_pos(lastPos):
	#uses last_pos to calculate new pos
	#Check left down and then up
	if orientation == Vector2(-1,0):
		if NodeMap.returnNode_by_mappos(lastPos+orientation).get_tileType() == NodeMap.TILES.SEA:
			return lastPos + orientation
		elif NodeMap.returnNode_by_mappos(lastPos+Vector2(0,-1)).get_tileType() == NodeMap.TILES.SEA:
			orientation = Vector2(0,-1)
			return lastPos + Vector2(0,-1)
		elif NodeMap.returnNode_by_mappos(lastPos+Vector2(0,1)).get_tileType() == NodeMap.TILES.SEA:
			orientation = Vector2(0,1)
			return lastPos + Vector2(0,1)
	elif orientation == Vector2(0,1) or orientation == Vector2(0,-1):
		if NodeMap.returnNode_by_mappos(lastPos+orientation).get_tileType() == NodeMap.TILES.SEA:
			return lastPos + orientation
	return "error"

	
func play(anim, pos):
	if anim == "build":
		initPos = pos
		var buildAnim = Animation.new()
		var track1 = buildAnim.add_track(Animation.TYPE_METHOD, 0)
		buildAnim.set_length(LENGTH)
		var tempPos = pos
		for i in range(0,LENGTH):
			buildAnim.track_insert_key(0, i*BUILD_SPEED, {"method": "build_bridge", "args": [tempPos]})
			var ret = get_next_pos(tempPos)
			if typeof(ret) == TYPE_STRING and ret == "error":
				print("Bridge cannot go further")
				break
			tempPos = ret
		animPlayer.add_animation("build", buildAnim)
	animPlayer.play(anim)

func init(nodeMapPath):
	NodeMap = nodeMapPath

func _ready():
	pass
	
