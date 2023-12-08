extends CharacterBody2D

#MOVEMENT VARIABLES
@export var speed = 350
@export var defaultSpeed = 350
@export var jumpVel = -400
@export var hp = 100.0
@export var wallJumpKick = 1000
@export var sprintSpeed = 400
@export var accel = 40 #69
@export var dashSpeed = 450
@export var dashAccel = 150

#GUN VARIABLES
@export var fireRate = .2
@export var reserveAmmo : int = 90
@export var magCap : int = 15
@export var currentAmmo : int = 15
@export var reloadSpeed = 0.2

@onready var rayCast2D = $Hand/Pistol/RayCast2D
@onready var coyoteTimer = $CoyoteTimer
@onready var player = $"."
@onready var camera2D = $Camera2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumpAvailible : bool = true
var dead : bool = false
var muzzleFlashShowing : bool = false
var wallJumpLimit : int = 0
var lastMoveDir = null # 0 Means Left. 1 Means Right
var isSlowMo : bool = false
var isShooting : bool = false
var zoomX = 4 # Tryna add aiming but first i gotta now how lerp works on anything other than movement
var zoomY = 4
var zoom = 12
var isDashing : bool = false

func _physics_process(delta):
# ------ Debugging ------- #

	#print(wallJumpLimit)
	#print("lastMoveDir is ", lastMoveDir)
	print("Mag = ", currentAmmo)
	print("Reserve ammo ", reserveAmmo)
	#print(mousePos)
	print("Status of jumpAvailible is ", jumpAvailible)
	print("iudfsindfs",  wallJumpLimit)
	
# ------ Slow-Mo (Will make more use of cuz slow-mo is hella kewl) ------- #
	if Input.is_action_pressed("slowMo") and isSlowMo == false:
		Engine.time_scale = 0.5
		isSlowMo = true 
	elif Input.is_action_just_released("slowMo") and isSlowMo == true:
		Engine.time_scale = 1
		isSlowMo = false
		
# ------ Handles Movement checking ------- #
		
	if Input.is_action_just_pressed("moveLeft"):
		lastMoveDir = 0
	elif Input.is_action_just_pressed("moveRight"):
		lastMoveDir = 1
		
	#if Input.is_action_pressed("sprint"): ( had to get rid of the sprinting cuz it messed up with the acceleration
										#   i WILL replace it with a dashing mechanic)
		#speed = sprintSpeed
	#else:
		#speed = defaultSpeed
		
# ------ Inevitable Death ------- #

	if hp < 0 or hp == 0:
		kill()
		
# ------ Coyote Time ------- #

#FIXME broken (inf jump) i got a feeling it has to do with the coyoteTimer
	if not is_on_floor():
		velocity.y += gravity * delta
		if jumpAvailible == true and coyoteTimer.is_stopped():
			coyoteTimer.start()
	else:
		jumpAvailible = true
		wallJumpLimit = 0

# ------ Gun system with a shitty reload script ------- #

	if Input.is_action_just_pressed("reload") and currentAmmo != magCap:
		reserveAmmo += currentAmmo
		currentAmmo = 0
		await get_tree().create_timer(reloadSpeed).timeout
		currentAmmo = magCap
		reserveAmmo -= magCap 
		# I should really turn this reload script into a function
		
	if currentAmmo > magCap:
		currentAmmo = magCap
		
	if Input.is_action_just_pressed("shoot") and isShooting == false and currentAmmo != 0:
		shoot()
		
# ------ Wall jumping ------- #
	if is_on_wall_only() and jumpAvailible:
		jumpAvailible = false
	if is_on_wall() and Input.is_action_just_pressed("jump") and wallJumpLimit != 3 and lastMoveDir == 1:
		velocity.y = jumpVel
		wallJumpLimit += 1
	elif is_on_wall() and Input.is_action_just_pressed("jump") and wallJumpLimit != 3 and lastMoveDir == 0:
		velocity.y = jumpVel
		wallJumpLimit += 1

# ------ Aiming ------- #

	var mousePos = get_global_mouse_position()
	rayCast2D.look_at(mousePos)

# ------ Jumping with coyote time ------- #

	if Input.is_action_just_pressed("jump") and jumpAvailible:
		velocity.y = jumpVel
		jumpAvailible = false
	#if not is_on_floor():
		#velocity.y += gravity * delta
		
# ------ Movement with acceleration ------- #

	if Input.is_action_pressed("moveRight"):
		velocity.x += accel
		$Sprite2D.flip_h = false
	elif Input.is_action_pressed("moveLeft"):
		velocity.x -= accel
		$Sprite2D.flip_h = true
	else:
		velocity.x = lerpf(velocity.x,0,0.1)
	
	velocity.x = clamp(velocity.x, -speed, speed)

	move_and_slide()

# ------ Functions!! ------- #

func shoot():
	currentAmmo -= 1
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

# if youre reading this i appericatebasdjis that youre wasting your time to look at my shitty code 
# that NEEDS optimisation
# also i added all these comments to make my code easier to go through if anyone wants to fork this or what ever
# but REMEMBER its GPLv3 licensed you HAVE to publish the source-code because free software == good
