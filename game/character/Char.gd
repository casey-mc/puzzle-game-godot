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
onready var bridgePattern0 = preload("res://tiles/bridepattern0.tscn")
onready var turningBridge = preload("res://tiles/TurningBridge.tscn")
# Bridge patterns:
# Patterns are {relativemappos:[[accepted tiles], final tile]}
# (0,0) is click position
# -1 in final tile means tile is unchanged
# Pattern0 checks 1 south of click position and 7 north
#onready var bridgePattern0 = {
#                              Vector2(0,1):[[1, 2],-1],
#                              Vector2(0,0):[[0], 2],
#                              Vector2(0,-1):[[0], 2],
#                              Vector2(0,-2):[[0], 2],
#                              Vector2(0,-3):[[0], 2],
#                              Vector2(0,-4):[[0], 2],
#                              Vector2(0,-5):[[0], 2],
#                              Vector2(0,-6):[[0], 2]
#                              }
# Pattern 1 checks 1 left of click position and 3 right
#onready var bridgePattern1 = {
#                                Vector2(-1,0):[[1, 2], -1],
#                                Vector2(0,0):[[0], 2],
#                                Vector2(1,0):[[0], 2],
#                                Vector2(2,0):[[0], 2]
#                             }

func _fixed_process(delta):

    if (Input.is_action_pressed("ui_left")):
        velocity.x = -WALK_SPEED
    elif (Input.is_action_pressed("ui_right")):
        velocity.x =  WALK_SPEED
    else:
        velocity.x = 0
    if (Input.is_action_pressed("ui_down")):
        velocity.y =  WALK_SPEED
    elif (Input.is_action_pressed("ui_up")):
        velocity.y = -WALK_SPEED
    else:
        velocity.y = 0
    var motion = velocity * delta
    move(motion)
    Resources.set_text(String(rockAmount))

func selection_box(enable):
	var box = get_node("Area2D/SelectionBox")
	if (enable == true):
		box.set_opacity(.75)
	elif (enable == false):
		box.set_opacity(0)

func _input(ev):
	if (ev.type==InputEvent.KEY):
		if (ev.is_action_pressed("ui_shift")):
			selection_box(true)
		elif(ev.is_action_released("ui_shift")):
			selection_box(false)

func _ready():
    timer.start()
    set_fixed_process(true)
    set_process_input(true)

func _on_Area2D_input_event( viewport, event, shape_idx ):
	var map_pos = Vector2() #position of click in TileMap coordinates
	var tileType # TileMap index at click location
   
   # Get location of click (and tile type) in TileMap coordinates
	if (event.type==InputEvent.MOUSE_BUTTON and event.is_pressed()):
		var node = NodeMap.returnNode(get_global_mouse_pos())
		tileType = node.get_tileType()
		var newNode
		if (tileType == 0):
			if (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(0,1)).get_tileType() == NodeMap.TILES.LAND):
				var newBridge = bridgePattern0.instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build",node.get_tileMapPos())
			elif (NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(1,0)).get_tileType() == NodeMap.TILES.BRIDGE):
				newNode = NodeMap.returnNode_by_mappos(node.get_tileMapPos()+Vector2(1,0))
				newNode.remove_child(newNode.get_node("StaticBody2D"))
				var newBridge = turningBridge.instance()
				newBridge.init(NodeMap)
				add_child(newBridge)
				newBridge.play("build", node.get_tileMapPos())

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
