extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#var NodeArray=[]

# for scene in /tiles, preload
onready var sceneArray = [preload("res://tiles/Sea.tscn"),preload("res://tiles/Land.tscn"),preload("res://tiles/Bridge_NS.tscn"),preload("res://tiles/Rock.tscn")]
onready var TileMap = get_node("TileMap")
onready var Char = get_node("../Char")
onready var localBox = {} #Dictionary defined as (x,y):Node where x and y are TileMap coordinates
onready var localPos

func _fixed_process(delta):
	update_localBox()

func update_localBox():
	var charPos = Char.get_pos()
	var mapPos = TileMap.world_to_map(charPos)
	var charArea = get_node("../Char/Area2D/CollisionShape2D")
	var playerBox = []
	if (localPos == mapPos):
		return
	else:
		for i in range(-2,2):
			for j in range(-2,2):
				playerBox.append(Vector2(mapPos.x+i,mapPos.y+j))
		for y in playerBox:
			if (!localBox.keys().has(y)):
				nodeify(y, TileMap.get_cellv(y))
		for x in localBox.keys():
			if (!playerBox.has(x) and !(localBox[x].get_groups().has("persistent"))):
				de_nodeify(x)
	localPos = mapPos

func de_nodeify(mapPos):
	var node = localBox[mapPos]
	node.get_tileType()
	TileMap.set_cellv(mapPos, node.get_tileType())
	localBox.erase(mapPos)
	node.queue_free()

# Function gets a mapPos, turns the TileMap cell to a node, and returns that node.
func nodeify(mapPos, type):
	if (type == -1):
		return
	TileMap.set_cellv(mapPos, -1)
	# TODO: make -1 not go to end of array, causes bug: sceneArray[-1] gets instanced
	var newNode = sceneArray[type].instance()
	add_child(newNode)
	newNode.set_pos(TileMap.map_to_world(mapPos)+Vector2(10,10))
	newNode.set_tileMapPos(mapPos)
	newNode.add_to_group("persistent")
	# TODO: refactor these lines into the tile scripts
#	if (newNode.get_tileType() == 2):
#		newNode.add_to_group("persistent")
	if (newNode.get_tileType() == 3):
		newNode.get_node("Area2D").connect("body_enter",get_node("../Char"),"_ownRock",[newNode])
#		newNode.add_to_group("persistent")
	localBox[mapPos] = newNode
	return

# Takes in a global mouse position, returns the node at location or null if not in localBox
# TODO: What if there is a tile but not a node at the position?
func returnNode(globalPos):
	var mapPos = TileMap.world_to_map(globalPos)
	if (!localBox.keys().has(mapPos)):
		nodeify(mapPos, TileMap.get_cellv(mapPos))
	return localBox[mapPos]

func get_north(node):
	var pos = node.get_tileMapPos()
	pos = pos + Vector2(0,-1)
	if (!localBox.keys().has(pos)):
		nodeify(pos, TileMap.get_cellv(pos))
	return localBox[pos]

func get_mapPos(pos):
	return TileMap.world_to_map(pos)

func placeTile(mapPos, tileType):
	if (localBox.keys().has(mapPos)):
		if (tileType == localBox[mapPos].get_tileType()):
			return
		else:
			de_nodeify(mapPos)
			nodeify(mapPos, tileType)

func _select(which):
	var nodeBridge = sceneArray[2].instance()
	which.add_child(nodeBridge)
	nodeBridge.set_opacity(.5)
	
func _deselect(which):
#	var bridge = which.get_node("Bridge_NS") #TODO: Handle different bridge types. Or tiles altogether.
	var bridge = which.get_child(2)
	#which.remove_child(bridge)
	if (bridge != null):
		bridge.queue_free()


func _ready():
	set_fixed_process(true)
	set_process_input(true)