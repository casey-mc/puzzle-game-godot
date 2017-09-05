extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var NodeMap
var direction
var initialDirection
var LENGTH = 15
var lastPos
var BUILD_SPEED = 1
onready var myTween = get_node("Tween")

func build_bridge():
	NodeMap.placeTile(lastPos, NodeMap.TILES.RANDOMBRIDGE)
	# Get tileTypes of adjacent nodes
	# For Nodes that are type SEA, give them an equal chance to be the next direction
	# Give the node that was the last direction a 20% bigger chance than the other two
	# LastPos = lastPos + direction
	var adjNodes = NodeMap.get_adj_nodes(lastPos)
	var seaNodes = float(0)
	var chanceDict = {}
	# Get total count of available placement options
	for direction in adjNodes:
		if adjNodes[direction].get_tileType() == 0:
			chanceDict[direction] = 0
			seaNodes = seaNodes + 1
	# If there are no adjacent seaNodes, or just one, bail out or use that one
	if seaNodes == 0:
		return
	if seaNodes == 1:
		for x in chanceDict:
			lastPos = lastPos + x
		return
	# Assign a chance to each placement option
	var chanceEqual = float(1/seaNodes)
	var chanceWeight
	if adjNodes[initialDirection].get_tileType() == 0:
		chanceWeight = (seaNodes-1)*.05
		chanceEqual = chanceEqual-chanceWeight
		chanceWeight = chanceEqual + chanceWeight*(seaNodes)
		chanceDict[initialDirection] = chanceWeight
	for direction in chanceDict:
		if direction != initialDirection:
			chanceDict[direction] = chanceEqual
	# TODO: Implement a weight on choosing a block that is in the same direction
	# Right now it's a little too random. It should want to choose tiles in a way that avoids huge blocks
	randomize()
	var choice = rand_range(0,1)
	print("Random number is: ",choice)
	var total = 0
	var realChoice
	for x in chanceDict:
		total = total + chanceDict[x]
		print("Total is: %f at index %s" % [total, x])
		if choice <= total:
			realChoice = x
			break
	if (realChoice == null): # Just in case the number is out of bounds
		for key in chanceDict: 
			realChoice = key
	lastPos = lastPos+realChoice
	

func play(anim, pos, orientation):
	if (anim == "build"):
		initialDirection = orientation
		direction = orientation
		lastPos = pos
#		NodeMap.placeTile(lastPos, NodeMap.TILES.RANDOMBRIDGE)
		for i in range(0,LENGTH):
			myTween.interpolate_callback(self, i*BUILD_SPEED, "build_bridge")
		myTween.start()

func init(nodeMapLoc):
	NodeMap = nodeMapLoc

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
