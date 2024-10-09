extends CharacterBody2D

class_name Player

signal healthChanged

@export var speed: int = 35
@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtBox = $hurtBox
@onready var hurtTimer = $hurtTimer
@onready var weapon: Node2D = $weapon

@export var maxHealth: int = 3
@onready var currentHealth: int = maxHealth

@export var inventory: Inventory

@export var knockbackPower: int = 600

var lastAnimDirection: String = "Down"
var isHurt: bool = false
var isAttacking: bool = false

func _ready() -> void:
	weapon.disable()
	effects.play("RESET")

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
func attack():
	animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.enable()
	await animations.animation_finished
	weapon.disable()
	isAttacking = false
	
	

func updateAnimation():
	if isAttacking:
		return
		
		
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
		lastAnimDirection = direction

func handleCollision() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#print_debug(collider.name)
	

func _physics_process(delta: float) -> void:
	handleInput()
	move_and_slide()
	handleCollision()
	updateAnimation()
	if !isHurt:
		for area in hurtBox.get_overlapping_areas():
			if area.name == "hitBox":
				hurtByEnemy(area)
	
func  hurtByEnemy(area):
		currentHealth -= 1
		if currentHealth == 0:
			currentHealth = maxHealth
			
		healthChanged.emit(currentHealth)
		isHurt = true
		knockback(area.get_parent().velocity)
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		isHurt = false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.has_method("collect"):
		area.collect(inventory)
	
		#if hurtTimer.is_stopped():
			#
			#currentHealth -= 1
			#

		
		
		
func knockback(enemyVelocity: Vector2):
	var knockbackDirection: Vector2 = (enemyVelocity - velocity).normalized()*knockbackPower
	velocity = knockbackDirection
	#print_debug(velocity)
	#print_debug(position)
	move_and_slide()
	#print_debug(position)
	#print_debug(" ")


func _on_hurt_box_area_exited(area: Area2D) -> void:
	pass
