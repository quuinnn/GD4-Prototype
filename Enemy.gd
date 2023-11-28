extends CharacterBody2D


@export var speed = 200.0
@export var jumpVel = -400.0
@export var hp = 50
@export var knockback = 1000 #Attempted to add knockback to the takedamage() function. didnt work.. will try again
@export var damage = 5

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
var lastMoveDir = null # 0 means right 1 means left
var chasingPlayer : bool = true #fur die knockback

func _physics_process(delta):
# ------ Debugging ------- #

	print("Enemy Hp = ", hp)
	print("Last move dir = ", lastMoveDir)
	
# ------ Chase player & Movement script ------- #

	if not chasingPlayer:
		return
	var dirToPlayer = global_position.direction_to(player.global_position)
	var lookPlayer = player.global_position
	rayCast2D.look_at(lookPlayer)
	collisionthing.look_at(lookPlayer)
	velocity.x = dirToPlayer.x * speed
	if not is_on_floor():
		velocity.y += gravity * delta
	
# ------ Adds the spooky scary blood ------- #
	
	if takeDamageBloodAvailible != true:
		takeDamageBlood.emitting = false
	
	if velocity.x > 0 and takeDamageBloodAvailible:
		sprite2D.flip_h = false
		takeDamageBlood.direction.x = -1
	if velocity.x < 0 and takeDamageBloodAvailible:
		sprite2D.flip_h = true
		takeDamageBlood.direction.x = 1
	if velocity.x < 0:
		lastMoveDir = 1
	elif velocity.x > 0:
		lastMoveDir = 0
	if takeDamageBloodAvailible == true and takeDamageBlood.emitting == true:
		bloodEmitFalse()
		
	# ------ Kills the enemy ------- #
	
	if dead:
		return
	if hp < 0 or hp == 0:
		dead = true
		hp = 0
	if dead == true:
		kill()
		
	# ------ ???? What's the purpose of this? Why'd I even... never mind ------- #
	
	if is_on_wall() and is_on_floor() and rayCast2D.get_collider() != player:
		velocity.y = jumpVel
	#if collisionthing.is_colliding():
		#velocity.x = 0.0
	
	move_and_slide()

func takeDamage():
	hp -= damage
	chasingPlayer = false
	if takeDamageBloodAvailible:
		takeDamageBlood.emitting = true
	if chasingPlayer == false:
		await get_tree().create_timer(.07).timeout
		chasingPlayer = true
		
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
