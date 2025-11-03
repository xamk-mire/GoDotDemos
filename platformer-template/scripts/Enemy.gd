extends CharacterBody2D

@export var speed: float = 60.0
@export var gravity: float = 1400.0

# Ray lengths (tweak to your sprite size)
@export var wall_len: float = 12.0
@export var ledge_ahead: float = 8.0
@export var ledge_drop: float = 16.0

var direction: int = -1 # -1 = left, 1 = right

@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_check: RayCast2D = $WallCheck
@onready var ledge_check: RayCast2D = $LedgeCheck


func _ready() -> void:
	wall_check.enabled = true
	ledge_check.enabled = true
	sprite.flip_h = (direction < 0)
	_update_rays()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * speed

	# Turn if there is a wall ahead or no ground ahead
	if wall_check.is_colliding() or not ledge_check.is_colliding():
		_flip()

	move_and_slide()


func _flip() -> void:
	direction *= -1
	sprite.flip_h = (direction < 0)
	_update_rays()


func _update_rays() -> void:
	# Cast to the side we’re moving
	wall_check.target_position = Vector2(wall_len * direction, 0)
	ledge_check.target_position = Vector2(ledge_ahead * direction, ledge_drop)
