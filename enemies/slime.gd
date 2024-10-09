extends CharacterBody2D

@export var speed: int = 20
@export var limit: float = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimationPlayer

var startPosition: Vector2
var endPosition: Vector2

var isDead: bool = false

func _ready() -> void:
	startPosition = position
	endPosition = endPoint.global_position

func changeDirection() -> void:
	var tempEnd: Vector2 = endPosition
	endPosition = startPosition
	startPosition = tempEnd

func updateVelocity() -> void:
	var moveDirection: Vector2 = endPosition - position
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized()*speed

func updateAnimation() -> void:
	#var animationString: String = "walkUp"
	#if velocity.y > 0:
		#animationString = "walkDown"
		#
	#animations.play(animationString)
	
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		elif velocity.y > 0: direction = "Down"

		animations.play("walk" + direction)
		
func _physics_process(delta: float) -> void:
	if isDead:
		return
	updateVelocity()
	move_and_slide()
	updateAnimation()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area == $hitBox:
		return
	$hitBox.set_deferred("monitorable", false)
	isDead = true
	animations.play("death")
	await animations.animation_finished
	queue_free()
