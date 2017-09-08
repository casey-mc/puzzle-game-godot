extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#var NodeArray=[]

# for scene in /tiles, preload
# needs wall tile
onready var sceneArray = [preload("res://tiles/Sea.tscn"),preload("res://tiles/Land.tscn"),
							preload("res://tiles/Bridge.tscn"),preload("res://tiles/Rock.tscn"),
							preload("res://tiles/SeaRocks.tscn"), preload("res://tiles/TurningBridgeTile.tscn"),
							preload("res://tiles/RandomBridge.tscn")]
enum TILES {SEA, LAND, BRIDGE, ROCK, SEAROCKS, TURNINGBRIDGETILE, RANDOMBRIDGE}
const sourceTiles = [TILES.BRIDGE, TILES.TURNINGBRIDGETILE, TILES.RANDOMBRIDGE]
const NORTH = Vector2(0,-1)
const SOUTH = Vector2(0,1)
const EAST = Vector2(1,0)
const WEST = Vector2(-1,0)
onready var myTileMap = get_child(0)
onready var Char = get_node("../Char")
onready var localBox = {} #Dictionary defined as (x,y):Node where x and y are TileMap coordinates
onready var localPos
onready var bridgePattern0 = preload("res://tiles/bridepattern0.tscn")
var tileSize
# NESW:
onready var compass = [Vector2(0,-1),Vector2(1,0), Vector2(0,1), Vector2(-1,0)]

func _fixed_process(delta):
	update_localBox()

func update_localBox():
	var charPos = Char.get_pos()
	var mapPos = myTileMap.world_to_map(charPos)
	var playerBox = []
	if (localPos == mapPos):
		return
	else:
		for i in range(-2,2):
			for j in range(-2,2):
				playerBox.append(Vector2(mapPos.x+i,mapPos.y+j))
		for y in playerBox:
			if (!localBox.keys().has(y)):
				nodeify(y, myTileMap.get_cellv(y))
		for x in localBox.keys():
			if (!playerBox.has(x) and !(localBox[x].get_groups().has("persistent"))):
				de_nodeify(x)
	localPos = mapPos

func de_nodeify(mapPos):
	var node = localBox[mapPos]
	if node == Char.highlighted_plus:
		Char.highlighted_plus = null
	node.get_tileType()
	myTileMap.set_cellv(mapPos, node.get_tileType())
	localBox.erase(mapPos)
	node.queue_free()

# Function gets a mapPos, turns the TileMap cell to a node, and returns that node.
func nodeify(mapPos, type):
	if (type == -1):
		return
	myTileMap.set_cellv(mapPos, -1)
	# TODO: make -1 not go to end of array, causes bug: sceneArray[-1] gets instanced
	var newNode = sceneArray[type].instance()
	add_child(newNode)
	newNode.set_pos(myTileMap.map_to_world(mapPos)+Vector2(10,10))
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
func returnNode(globalPos):
	var mapPos = myTileMap.world_to_map(globalPos)
	if (!localBox.keys().has(mapPos)):
		nodeify(mapPos, myTileMap.get_cellv(mapPos))
	return localBox[mapPos]
	
func returnNode_by_mappos(mapPos):
	if (!localBox.keys().has(mapPos)):
		nodeify(mapPos, myTileMap.get_cellv(mapPos))
	return localBox[mapPos]

func get_mapPos(pos):
	return myTileMap.world_to_map(pos)
	
func get_worldPos(pos):
	return myTileMap.map_to_world(pos)

func placeTile(mapPos, tileType):
	if (localBox.keys().has(mapPos)):
		if (tileType == localBox[mapPos].get_tileType()):
			return
		else:
			de_nodeify(mapPos)
			nodeify(mapPos, tileType)

# Get nodes adjacent to map pos
# Returns a dictionary 
func get_adj_nodes(pos):
	var ret = {}
	ret[NORTH] = returnNode_by_mappos(pos+NORTH)
	ret[SOUTH] = returnNode_by_mappos(pos+SOUTH)
	ret[EAST] = returnNode_by_mappos(pos+EAST)
	ret[WEST] = returnNode_by_mappos(pos+WEST)
	return ret
	
func get_adj_node(pos, dir):
	return returnNode_by_mappos(pos + dir)

#func _select(which):
#	var nodeBridge = bridgePattern0.instance()
#	nodeBridge.set_pos(myTileMap.map_to_world(which.get_myTileMapPos())+Vector2(10,10))
#	nodeBridge.add_to_group("outline")
#	nodeBridge.init(self)
#	which.add_child(nodeBridge)
#	nodeBridge.play("outline",0)
#	
#func _deselect(which):
#	for node in which.get_children():
#		if node.get_groups().has("outline"):
#			node.stop("outline")
#			which.remove_child(node)


func _ready():
	tileSize = myTileMap.get_cell_size()
	set_fixed_process(true)
	set_process_input(true)