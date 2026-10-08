extends Node2D

const SPEED = 30
var direction = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@onready var right: RayCast2D = $right
@onready var aslime: AnimatedSprite2D = $AnimatedSprite2D
@onready var left: RayCast2D = $left


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if right.is_colliding():
		direction-=1
		aslime.flip_h=true
	if left.is_colliding():
		direction+=1	
		aslime.flip_h=false
	position.x += direction*SPEED *delta
