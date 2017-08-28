extends KinematicBody2D

# TODO: Set this as a function of Tile size
const WALK_SPEED = 50

var velocity = Vector2()
onready var NodeMap = get_node("../NodeMap")
onready var TileMap = get_node("../NodeMap/TileMap")
onready var ownedRocks = []
onready var Timer = get_node("Timer")
onready var Resources = get_node("../Resources")
onready var rockAmount = 0
onready var resources = 0
#onready var selectionBox = false

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
    Timer.start()
    set_fixed_process(true)
    set_process_input(true)

func _on_Area2D_input_event( viewport, event, shape_idx ):
	var map_pos = Vector2() #position of click in TileMap coordinates
	var tileType # TileMap index at click location
   
   # Get location of click (and tile type) in TileMap coordinates
	if (event.type==InputEvent.MOUSE_BUTTON):
		var node = NodeMap.returnNode(get_global_mouse_pos())
		tileType = node.get_tileType()
		if (tileType == 0):
			create_bridge(node) #This function handles getting the tile positions and creating the bridges

func create_bridge(node):
	var north = Vector2(0,-1)
	var south = Vector2(0,1)
	var node2 = NodeMap.get_adj_node(node, north)
	var node3 = NodeMap.get_adj_node(node2, north)
	var node4 = NodeMap.get_adj_node(node, south)
	if (node.get_tileType() == 0 and node2.get_tileType() == 0 and node3.get_tileType() == 0 and
			(node4.get_tileType() == 1 or node4.get_tileType() == 2)):
		NodeMap.placeTile(node.get_tileMapPos(), 2)
		NodeMap.placeTile(node2.get_tileMapPos(), 2)
		NodeMap.placeTile(node3.get_tileMapPos(), 2)
		


func _new_resource(thisischar, resource):
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
