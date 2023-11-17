extends CharacterBody2D


@export var speed = 200.0
@export var jumpVel = -400.0
@export var hp = 50

@onready var player = $"../Player"
@onready var rayCast2D = $RayCast2D
@onready var collisionthing = $collisionthing
@onready var blood = $Blood
@onready var sprite2D = $Sprite2D
@onready var collisionShape2D = $CollisionShape2D
@onready var takeDamageBlood = $takeDamageBlood

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead : bool = false
var isAttacking : bool = false
var takeDamageBloodAvailible : bool = true

func _physics_process(delta):
	print("Enemy Hp = ", hp)
	var dirToPlayer = global_position.direction_to(player.global_position)
	var lookPlayer = player.global_position
	rayCast2D.look_at(lookPlayer)
	collisionthing.look_at(lookPlayer)
	velocity.x = dirToPlayer.x * speed
	
	if takeDamageBloodAvailible != true:
		takeDamageBlood.emitting = false
	
	if velocity.x > 0 and takeDamageBloodAvailible:
		sprite2D.flip_h = false
		takeDamageBlood.direction.x = -1
	if velocity.x < 0 and takeDamageBloodAvailible:
		sprite2D.flip_h = true
		takeDamageBlood.direction.x = 1

	if not is_on_floor():
		velocity.y += gravity * delta
	if dead:
		return
	if hp < 0 or hp == 0:
		dead = true
		hp = 0
	if dead == true:
		kill()
		
	if is_on_wall() and is_on_floor() and rayCast2D.get_collider() != player:
		velocity.y = jumpVel
	if takeDamageBloodAvailible == true and takeDamageBlood.emitting == true:
		bloodEmitFalse()
	#if collisionthing.is_colliding():
		#velocity.x = 0.0
	
	move_and_slide()

func takeDamage():
	hp -= 10
	if takeDamageBloodAvailible:
		takeDamageBlood.emitting = true
		
func bloodEmitFalse():
	if takeDamageBloodAvailible:
		await get_tree().create_timer(.3).timeout
		takeDamageBlood.emitting = false
	
func kill():
	sprite2D.queue_free()
	collisionShape2D.queue_free()
	blood.emitting = true
	takeDamageBloodAvailible = false
	
func dealDamage():
	if rayCast2D.is_colliding() and rayCast2D.get_collider().has_method("takeDamage"):
		rayCast2D.get_collider().takeDamage()
