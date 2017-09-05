extends KinematicBody2D

# TODO: Set this as a function of Tile size
const WALK_SPEED = 100

var velocity = Vector2()
onready var NodeMap = get_node("../NodeMap")
onready var TileMap = get_node("../NodeMap/TileMap")
onready var ownedRocks = []
onready var timer = get_node("Timer")
onready var Resources = get_node("../HUD/Resources")
onready var rockAmount = 0
onready var resources = 0
var highlighted_plus
onready var bridgesArray = [preload("res://tiles/bridepattern0.tscn"), preload("res://tiles/TurningBridge.tscn"), preload("res://tiles/RandomBridgePattern.tscn")]
var adjNodes
var selecting = false
var targetDirection
var isMoving
var targetPos

func _fixed_process(delta):
	var direction = Vector2()
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
		isMoving = false
		# If the player is moving diagonally into a wall, he can get off the center of a tile because the normal pushes him back diagonally
		if direction.x != 0 or direction.y !=0:
			return
		move(get_collision_normal())
	# Move the character
	if not isMoving and direction != Vector2():
		targetDirection = direction
		# TargetPos is the center of a NodeMap tile in targetDirection
		targetPos = NodeMap.get_worldPos(NodeMap.get_mapPos(get_pos())+targetDirection)+(NodeMap.tileSize/2)
#		targetPos = get_pos() + NodeMap.tileSize * targetDirection
		isMoving = true
	elif isMoving:
		velocity = WALK_SPEED * targetDirection.normalized() * delta
		var pos = get_pos()
		var distanceToTarget = Vector2(abs(targetPos.x-pos.x), abs(targetPos.y-pos.y))
		if abs(velocity.x) > distanceToTarget.x:
			velocity.x = distanceToTarget.x * targetDirection.x
			isMoving = false
		if abs(velocity.y) > distanceToTarget.y:
			velocity.y = distanceToTarget.y * targetDirection.y
			isMoving = false
		move(velocity)
		
	# Display UI
	Resources.set_text(String(rockAmount))


func _input(ev):
	var highlightDirection = Vector2(0,0)
	if (ev.type==InputEvent.KEY):
		# Camera stuff
		# TODO: Animate this property with a tween
		if (ev.is_action_pressed("player_zoom")):
			get_node("Camera2D").set_zoom(Vector2(2,2))
		elif (ev.is_action_released("player_zoom")):
			get_node("Camera2D").set_zoom(Vector2(1,1))
		
		# Building/selection stuff
		if (ev.is_action_pressed("ui_shift")):
			selecting = true
		elif(ev.is_action_released("ui_shift")):
			for node in adjNodes.values():
				if node.get_tileType() == 0:
					node.set_modulate(Color(1,1,1))
			highlighted_plus = null
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
		if (ev.is_action_pressed("ui_accept") and selecting == true and highlighted_plus != null):
			var map_pos = Vector2() #position of click in TileMap coordinates
			var tileType # TileMap index at click location
			var node = highlighted_plus
			tileType = node.get_tileType()
			var newNode
			var adjNode
			if (NodeMap.returnNode_by_mappos(highlighted_plus.get_tileMapPos()+NodeMap.SOUTH).get_tileType() == NodeMap.TILES.LAND):
				print("Build Bridge")
				var newBridge = bridgesArray[0].instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build",highlighted_plus.get_tileMapPos())
			# Check left and right of bridge
			elif (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(-1,0)).get_tileType() == NodeMap.TILES.BRIDGE):
				var newBridge = bridgesArray[2].instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build", node.get_tileMapPos(), Vector2(1,0))
			elif (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(1,0)).get_tileType() == NodeMap.TILES.BRIDGE or
			NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(-1,0)).get_tileType() == NodeMap.TILES.BRIDGE):
				if (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(1,0)).get_tileType() == NodeMap.TILES.BRIDGE):
					adjNode = Vector2(1,0)
				elif (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(-1,0)).get_tileType() == NodeMap.TILES.BRIDGE):
					adjNode = Vector2(-1,0)
				var newBridge = bridgesArray[1].instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build", node.get_tileMapPos(), -adjNode)
			highlighted_plus = null

func _ready():
	timer.start()
	set_pos(NodeMap.get_worldPos(Vector2(6,4))+NodeMap.tileSize/2)
	set_fixed_process(true)
	set_process_input(true)


func _new_resource(char, resource):
	resource.queue_free()
	resources = resources + 1
	print(resources)
	
func _ownRock(thisischar, rock):
	if rock.get_owned() == false:
		rock.set_owned(true)
		ownedRocks.append(rock)
		print("You own rock #",rock.get_name())


func _on_Timer_timeout():
	rockAmount = rockAmount + ownedRocks.size()*2
