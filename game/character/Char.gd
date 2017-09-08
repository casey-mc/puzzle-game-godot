extends KinematicBody2D

# TODO: Set this as a function of Tile size
const WALK_SPEED = 100

onready var NodeMap = get_node("../NodeMap")
onready var HUD = get_node("../HUD/HBoxContainer")
var bridgeCount = {
"Bridge0" : 0,
"TurningBridge" : 0,
"RandomBridge" : 0,
}
var highlighted_plus
onready var bridgesArray = [preload("res://tiles/bridepattern0.tscn"), preload("res://tiles/TurningBridge.tscn"), preload("res://tiles/RandomBridgePattern.tscn")]
var adjNodes
var selecting = false
var targetDirection
var isMoving
var targetPos
var bridgeState = 0

func _fixed_process(delta):
	# Draw UI
	# This should all be event driven
	for child in HUD.get_children():
		child.get_node("Label").set_text(String(bridgeCount[child.get_name()]))
#	for x in range(0,HUD.get_child_count()):
#		print(HUD.get_child(x).get_type())
#		HUD.get_child(x).get_node("Label").set_text(String(bridgeCount[HUD.get_child(x)]))
	if bridgeState == 0:
		HUD.get_node("TurningBridge").set_modulate(Color(1,1,1))
		HUD.get_node("RandomBridge").set_modulate(Color(.5,.5,.7))
	elif bridgeState == 1:
		HUD.get_node("RandomBridge").set_modulate(Color(1,1,1))
		HUD.get_node("TurningBridge").set_modulate(Color(.5,.5,.7))
		
	
	# Choose node character is selecting
	adjNodes = NodeMap.get_adj_nodes(NodeMap.get_mapPos(get_pos()))
	if selecting == true:
		for node in adjNodes.values():
			if node.get_tileType() == 0 and not node == highlighted_plus:
				node.add_to_group("highlighted")
				if highlighted_plus == null:
					highlighted_plus = node
		for node in get_tree().get_nodes_in_group("highlighted"):
			if not adjNodes.values().has(node):
				node.set_modulate(Color(1,1,1))
				node.remove_from_group("highlighted")
				if highlighted_plus == node:
					highlighted_plus = null
			else:
				if node != highlighted_plus:
					node.set_modulate(Color(.5,.5,.5))
	elif selecting == false:
		for node in adjNodes.values():
			if node.get_tileType() == 0:
				node.set_modulate(Color(1,1,1))
		highlighted_plus = null
	
	# TODO: Here, play outline for selected bridge type
	if (highlighted_plus != null):
		var wr = weakref(highlighted_plus);
		if (!wr.get_ref()):
		     print("erased")
		else:
		    #object is fine so you can do something with it:
		    wr.get_ref().set_modulate(Color(.9,.9,.9))
#			highlighted_plus.set_modulate(Color(.9,.9,.9))
			#Wait a second, and then play outline for current bridge selection
	
	# Character movement
	var direction = Vector2()
	if (Input.is_action_pressed("player_left")):
	    direction.x = -1
	elif (Input.is_action_pressed("player_right")):
	    direction.x =  1
	else:
	    direction.x = 0
	if (Input.is_action_pressed("player_down")):
	    direction.y =  1
	elif (Input.is_action_pressed("player_up")):
	    direction.y = -1
	else:
	    direction.y = 0
	# If you're in a wall, bounce out of it.
	# This code sort of sucks but I like the feedback of the bounch
	# In the future, I'll check if the block in the direction would cause a collision
	# And then just play an animation that moves over the tile and back really quick
	if (is_colliding()):
		# Check if colliding with LodeStone
		# If so, move lodestone in direction of movement
		var collider = get_collider()
		print(collider)
		if collider.is_in_group("lodestones"):
			collider.myMove(targetDirection, get_collision_pos())
		isMoving = false
		# If the player is moving diagonally into a wall, he can get off the center of a tile because the normal pushes him back diagonally
#		if direction.x != 0 or direction.y !=0:
#			return
#		The following works unless the collision occures while the player is in the center of a tile but still colliding:
#		targetPos = NodeMap.get_worldPos(NodeMap.get_mapPos(get_pos())) + (NodeMap.tileSize/2)
		move(get_collision_normal())
	# Move the character
	elif !isMoving and direction != Vector2():
		targetDirection = direction
		targetPos = NodeMap.get_worldPos(NodeMap.get_mapPos(get_pos())+targetDirection)+(NodeMap.tileSize/2)
		isMoving = true
	elif isMoving:
		var velocity = WALK_SPEED * targetDirection.normalized() * delta
		var pos = get_pos()
		if pos.distance_to(targetPos) > velocity.length():
			move(velocity)
		else:
			move(targetPos-pos)
			isMoving = false


func _input(ev):
	var highlightDirection = Vector2(0,0)
	if (ev.type==InputEvent.KEY):
		# Camera stuff
		# TODO: Animate this property with a tween
		if (ev.is_action_pressed("player_zoom")):
			get_node("Camera2D").set_zoom(Vector2(2,2))
		elif (ev.is_action_released("player_zoom")):
			get_node("Camera2D").set_zoom(Vector2(1,1))
		
		if (ev.is_action_pressed("ui_change_state")):
			if bridgeState == 0:
				bridgeState = 1
			elif bridgeState == 1:
				bridgeState = 0
		
		# Building/selection stuff
		if (ev.is_action_pressed("ui_shift")):
			selecting = true
		elif(ev.is_action_released("ui_shift")):
			selecting = false
		if(ev.is_action_pressed("ui_left") and selecting == true):
			if adjNodes[NodeMap.WEST].get_tileType() == 0:
				highlightDirection = NodeMap.WEST
		elif(ev.is_action_pressed("ui_right") and selecting == true):
			if adjNodes[NodeMap.EAST].get_tileType() == 0:
				highlightDirection = NodeMap.EAST
		elif(ev.is_action_pressed("ui_up") and selecting == true):
			if adjNodes[NodeMap.NORTH].get_tileType() == 0:
				highlightDirection = NodeMap.NORTH
		elif(ev.is_action_pressed("ui_down") and selecting == true):
			if adjNodes[NodeMap.SOUTH].get_tileType() == 0:
				highlightDirection = NodeMap.SOUTH
			
		if highlightDirection != Vector2(0,0):
			var newHighlight = adjNodes[highlightDirection]
			if newHighlight != highlighted_plus:
				highlighted_plus = newHighlight

		# Here, build new bridge type
		# TODO: Eventually we'll need to clean up these bridge nodes
		# Probably could just implement a signal on them that fires when they are complete
		# Or maybe just a Tween at LENGTH + 1 that fires a self.queue_free()
		if (ev.is_action_pressed("ui_accept") and selecting == true and highlighted_plus != null):
			var node = highlighted_plus
			var adjNodes_H = NodeMap.get_adj_nodes(node.get_tileMapPos())
			var adjNode = Vector2()
			if (adjNodes_H[NodeMap.SOUTH].get_tileType() == NodeMap.TILES.LAND):
				print("Build Bridge")
				var newBridge = bridgesArray[0].instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build",highlighted_plus.get_tileMapPos())
				highlighted_plus = null
				return
			# Check left and right of bridge
			if NodeMap.sourceTiles.has(adjNodes_H[NodeMap.WEST].get_tileType()):
				adjNode = NodeMap.WEST
			elif NodeMap.sourceTiles.has(adjNodes_H[NodeMap.EAST].get_tileType()):
				adjNode = NodeMap.EAST
			if (adjNode != Vector2()):
				if bridgeState == 0:
					var newBridge = bridgesArray[1].instance()
					newBridge.init(NodeMap)
					add_child(newBridge)
					newBridge.play("build", node.get_tileMapPos(), -adjNode)
					highlighted_plus = null
				elif bridgeState == 1:
					var newBridge = bridgesArray[2].instance()
					newBridge.init(NodeMap)
					add_child(newBridge)
					newBridge.play("build", node.get_tileMapPos(), adjNode)
					highlighted_plus = null

func incr_res(recType, recAmount):
	for x in HUD.get_children():
		if x.get_name() == recType:
			bridgeCount[recType] = bridgeCount[recType] + recAmount

func _ready():
	set_pos(NodeMap.get_worldPos(Vector2(6,4))+NodeMap.tileSize/2)
	set_fixed_process(true)
	set_process_input(true)
