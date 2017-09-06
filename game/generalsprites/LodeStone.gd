extends KinematicBody2D

onready var NodeMap = get_node("../NodeMap")
var isMoving = false
var targetDirection = Vector2()
var targetPos
var WALK_SPEED = 100
var isLeft = false
var newMovement = false

func _fixed_process(delta):
	var velocity
	if newMovement:
		if isLeft == true:
			var leftCenter = get_pos()- Vector2(-10,0)
			targetPos = NodeMap.get_worldPos(NodeMap.get_mapPos(leftCenter)+targetDirection)+(NodeMap.tileSize/2)+Vector2(-10,0)
		elif isLeft == false:
			var rightCenter = get_pos()- Vector2(10,0)
			targetPos = NodeMap.get_worldPos(NodeMap.get_mapPos(rightCenter)+targetDirection)+(NodeMap.tileSize/2)+Vector2(10,0)
		newMovement = false
	if isMoving:
		velocity = WALK_SPEED * targetDirection.normalized() * delta
		var pos = get_pos()
		if pos.distance_to(targetPos) > velocity.length():
			move(velocity)
		else:
			print("Quit moving")
			move_to(targetPos)
#			move(targetPos-pos)
			isMoving = false
			targetDirection = Vector2()
			targetPos = Vector2()
			
func myMove(dir, colPos):
	var colSide = get_pos()- colPos
	if colSide.x > 0:
		isLeft = true
		print("hit left")
	elif colSide.x < 0:
		isLeft = false
		print("hit right")
	targetDirection = dir
	isMoving = true
	newMovement = true

func _ready():
	set_fixed_process(true)