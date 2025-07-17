extends CharacterBody2D

#MOVEMENT VARIABLES
@export var speed = null # Dummy variable so that the dashing stuff doesn't give me errors. I gotta remove that shit.
@export var topSpeed = 900
@export var defaultSpeed = 350 # Isn't being used?
@export var defaultAccel = 40 # Isn't being used?
@export var jumpVel = -400
@export var hp = 100.0
@export var wallJumpKick = 1000 # Isn't being used?
@export var accel = 40 #69
@export var accelFactor = 0.5 # Factor to slow down acceleration
@export var deaccel = 0.1
@export var airDeaccel = 0.010 # Should always be lower than deaccel
@export var crouchDeaccel = 0.05 # Should always be lower than deaccel, but higher than airDeaccel
@export var crouchAccel = 15
@export var dashSpeed = 690 # Isn't being used
@export var dashAccel = 300
@export var dashTimeout = .5

#GUN VARIABLES
@export var fireRate = .2
@onready var rayCast2D = $Hand/Pistol/RayCast2D
@onready var coyoteTimer = $CoyoteTimer
@onready var player = $"."
@onready var camera2D = $Camera2D
#@onready var frameFreezeMan = $"../frameFreeze"
var muzzleFlashShowing : bool = false

# MORE MOVEMENT VARIABLES
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumpAvailible : bool = true
var dead : bool = false
var wallJumpLimit : int = 0
var lastMoveDir = null # 0 Means Left. 1 Means Right
var isSlowMo : bool = false
var isShooting : bool = false
var isDashing : bool = false
var isCrouching : bool = false

func _physics_process(delta):
# ------ Debugging ------- #

	#print(wallJumpLimit)
	#print("lastMoveDir is ", lastMoveDir)
	#print(mousePos)
	#print("Status of jumpAvailible is ", jumpAvailible)
	#print("(Limit = 3) Status of wallJumpLimit is ",  wallJumpLimit)
	#print("Current HP is ", hp)
	print("Velocity X is ", int(velocity.x)) # The int() converts it to an interger for simplicity
	print("Velocity Y is ", int(velocity.y))
	
# ------ Slow-Mo (Will make more use of cuz slow-mo is hella kewl) ------- #
	if Input.is_action_pressed("slowMo") and isSlowMo == false:
		Engine.time_scale = 0.75
		isSlowMo = true
	elif Input.is_action_just_released("slowMo") and isSlowMo == true:
		Engine.time_scale = 1
		isSlowMo = false
		
# ------ Initiating Dashing ------ # Thiking 'bout scrapping this for a hoverboard mechanic like the one in Echo Point Nova

	if Input.is_action_just_pressed("sprint"):
		dash()
	if is_on_floor() and isDashing == true:
		stopDashing()
	if is_on_floor() and isDashing == false:
		accel = defaultAccel

# ------ Handles Movement Direction checking ------- #
		
	if Input.is_action_just_pressed("moveLeft"):
		lastMoveDir = 0
	elif Input.is_action_just_pressed("moveRight"):
		lastMoveDir = 1
		
# ------ Inevitable Death ------- #

	if hp < 0 or hp == 0:
		kill()
		
# ------ Coyote Time ------- #

	if not is_on_floor():
		velocity.y += gravity * delta
		if jumpAvailible == true and coyoteTimer.is_stopped():
			coyoteTimer.start()
	else:
		jumpAvailible = true
		wallJumpLimit = 0

# ------ Gun system ------- #

	if Input.is_action_just_pressed("shoot") and isShooting == false:
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
	#if Input.is_action_just_released("jump") && velocity.y < 0:
		#velocity.y = 0
		
# ------ Movement with acceleration ------- #

	var is_on_slope
	var floorNormal = get_floor_normal()
	var slopeAngle = floorNormal.angle()
	print("Slope angle = ", slopeAngle)
	print("Is on slope = ", is_on_slope)
	print("Is crouching = ", isCrouching)
	
	if Input.is_action_just_pressed("crouch"):
		crouch()

	if is_on_floor():
		#is_on_slope = false
		#floorNormal = get_floor_normal()
		#slopeAngle = floorNormal.angle()
		if slopeAngle < -0.8 and slopeAngle > -0.7:
			is_on_slope = true
		else:
			is_on_slope = false
		#if is_on_slope == true: #Need to sort out the is on slope stuff first.
			#if velocity.x != 0: 
				#velocity.y -= slopeAngle * speed * 0.5
	# Movement is frame-rate dependent. Needs to be fixed.
	if isCrouching == false: # Non-crouching acceleration
		if Input.is_action_pressed("moveRight"):
			velocity.x += accel * accelFactor # Applies acceleration and multiplies it by accelFactor
			$Sprite2D.flip_h = false
		elif Input.is_action_pressed("moveLeft"):
			velocity.x -= accel * accelFactor
			$Sprite2D.flip_h = true # Flips the sprite to match the direction of movement
	elif is_on_floor() and isCrouching == false:
		velocity.x = lerpf(velocity.x,0,deaccel) # Deaccelerates to 0 horizontal velocity, lower value equals longer time to deaccel to 0
	elif not is_on_floor() and isCrouching == false:
		velocity.x = lerpf(velocity.x,0,airDeaccel) # Same thing as before but for in air deacceleration which should always be lower then the former deaccel
	elif isCrouching and is_on_floor(): # Whilst crouching on floor
		velocity.x = lerpf(velocity.x,0,crouchDeaccel)
	if isCrouching: # Gonna continue this later
		if Input.is_action_pressed("moveRight"):
			velocity.x += crouchAccel  * accelFactor # Applies acceleration and multiplies it by accelFactor
			$Sprite2D.flip_h = false
		elif Input.is_action_pressed("moveLeft"):
			velocity.x -= crouchAccel * accelFactor
			$Sprite2D.flip_h = true # Flips the sprite to match the direction of movement
	velocity.x = clamp(velocity.x, -topSpeed, topSpeed) # Limits (Clamps) top speed.

	move_and_slide()

# ------ Functions!! ------- #

func shoot(): # Need to make this be projectile-based instead of ray-casting based
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

func dash():
	isDashing = true
	speed = dashSpeed
	accel = dashAccel
	#frameFreezeMan.frameFreeze()
	
func stopDashing():
	await get_tree().create_timer(dashTimeout).timeout
	speed = defaultSpeed
	#accel = defaultAccel
	if is_on_floor() and isDashing == true:
		isDashing = false
		
func crouch():
	if isCrouching == false:
		isCrouching = true
		$crouchingShape.disabled = false
		$crouchingShape2.disabled = false
		$normalShape.disabled = true
		$normalShape2.disabled = true
		$Sprite2D.scale.y = 0.211
		$Sprite2D.scale.x = 0.216
		$Sprite2D.position.y = 8.475
	else:
		isCrouching=false
		$crouchingShape.disabled = true
		$crouchingShape2.disabled = true
		$normalShape.disabled = false
		$normalShape2.disabled = false
		$Sprite2D.scale.y = 0.343
		$Sprite2D.scale.x = 0.216
		$Sprite2D.position.y = 0.0
