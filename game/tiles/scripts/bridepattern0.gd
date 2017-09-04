extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var bridge = preload("res://tiles/Bridge.tscn")
onready var animPlayer = get_node("AnimationPlayer")
var outlineBridge
var NodeMap
var initPos
var index = 0
var LENGTH = 5
var BUILD_SPEED = 1
var orientation = Vector2(0,-1)
	
func build_bridge(pos):
	# Place tile on NodeMap
	NodeMap.placeTile(pos, NodeMap.TILES.BRIDGE)

func bridge_translate():
	var tempPos = outlineBridge.get_pos()+Vector2(0,-20)
	outlineBridge.set_pos(tempPos)
	
func get_next_pos(lastPos):
	#uses last_pos to calculate new pos
	#Check then up
	if NodeMap.returnNode_by_mappos(lastPos+orientation).get_tileType() == NodeMap.TILES.SEA:
		return lastPos + orientation
	return "error"

func play(anim, pos):
	if (anim == "outline"):
		outlineBridge = bridge.instance()
		outlineBridge.set_opacity(.5)
		add_child(outlineBridge)
	elif (anim == "build"):
		initPos = pos
		var buildAnim = Animation.new()
		var track1 = buildAnim.add_track(Animation.TYPE_METHOD, 0)
		buildAnim.set_length(LENGTH)
		var tempPos = pos + Vector2(0,1)
		for i in range(0,LENGTH):
			tempPos = get_next_pos(tempPos)
			if typeof(tempPos) == TYPE_STRING:
				return
			buildAnim.track_insert_key(0, i*BUILD_SPEED, {"method": "build_bridge", "args": [tempPos]})
		animPlayer.add_animation("build", buildAnim)
	animPlayer.play(anim)
	
func stop(anim):
	if animPlayer.is_playing() and animPlayer.get_current_animation() == anim:
		animPlayer.stop()

func init(nodeMapPath):
	NodeMap = nodeMapPath
	

func _ready():
	# Reset status of node
	for child in get_children():
		if not child.get_groups().has("persistent"):
			child.queue_free()