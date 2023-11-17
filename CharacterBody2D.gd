extends CharacterBody2D

@export var speed = 350
@export var defaultSpeed = 350
@export var jumpVel = -400
@export var hp = 100.0
@export var wallJumpKick = 1000
@export var sprintSpeed = 400
@export var accel = 69
@export var dashSpeed = 450
@export var dashAccel = 150
@export var fireRate = .2

@onready var rayCast2D = $Hand/Pistol/RayCast2D
@onready var coyoteTimer = $CoyoteTimer
@onready var player = $"."

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumpAvailible : bool = true
var dead : bool = false
var muzzleFlashShowing : bool = false
var wallJumpLimit : int = 0
var lastMoveDir = null # 0 Means Left. 1 Means Right
var isSlowMo : bool = false
var isShooting : bool = false

var isDashing : bool = false
func _physics_process(delta):
	#print(wallJumpLimit)
	#print("lastMoveDir is ", lastMoveDir)
	if Input.is_action_pressed("slowMo") and isSlowMo == false:
		Engine.time_scale = 0.5
		isSlowMo = true 
	elif Input.is_action_just_released("slowMo") and isSlowMo == true:
		Engine.time_scale = 1
		isSlowMo = false
	if Input.is_action_just_pressed("moveLeft"):
		lastMoveDir = 0
	elif Input.is_action_just_pressed("moveRight"):
		lastMoveDir = 1
		
	#if Input.is_action_pressed("sprint"):
		#speed = sprintSpeed
	#else:
		#speed = defaultSpeed
	if Input.is_action_just_pressed("shoot") and isShooting == false:
		shoot()
	if hp < 0 or hp == 0:
		kill()
	if not is_on_floor():
		velocity.y += gravity * delta
		if jumpAvailible == true and coyoteTimer.is_stopped():
			coyoteTimer.start()
	else:
		jumpAvailible = true
		wallJumpLimit = 0
		
	if is_on_wall_only() and jumpAvailible:
		jumpAvailible = false
	if is_on_wall() and Input.is_action_just_pressed("jump") and wallJumpLimit != 3 and lastMoveDir == 1:
		velocity.y = jumpVel
		wallJumpLimit += 1
	elif is_on_wall() and Input.is_action_just_pressed("jump") and wallJumpLimit != 3 and lastMoveDir == 0:
		velocity.y = jumpVel
		wallJumpLimit += 1
		
	var mousePos = get_global_mouse_position()
	rayCast2D.look_at(mousePos)
	#print(mousePos)
	print("Status of jumpAvailible is ", jumpAvailible)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and jumpAvailible:
		velocity.y = jumpVel
		jumpAvailible = false
		
	if Input.is_action_pressed("moveRight"):
		velocity.x += accel
		$Sprite2D.flip_h = false
	elif Input.is_action_pressed("moveLeft"):
		velocity.x -= accel
		$Sprite2D.flip_h = true
	else:
		velocity.x = lerpf(velocity.x,0,0.2)
	
	velocity.x = clamp(velocity.x, -speed, speed)

	move_and_slide()
	
func shoot():
	isShooting = true
	$Hand/Pistol/MuzzleFlash.show()
	muzzleFlashShowing = true
	if rayCast2D.is_colliding() and rayCast2D.get_collider().has_method("takeDamage"):
		rayCast2D.get_collider().takeDamage()
		isShooting = true
	if isShooting:
		await get_tree().create_timer(fireRate).timeout 
		isShooting = false
	if muzzleFlashShowing and isShooting:
		await get_tree().create_timer(0.05).timeout
	$Hand/Pistol/MuzzleFlash.hide()
	muzzleFlashShowing = false

		
func kill():
	queue_free()
	
func _on_coyote_timer_timeout():
	jumpAvailible = false
	
func takeDamage():
	hp -= 10
