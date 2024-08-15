extends CharacterBody2D

#Basics Vars
var bullet = preload("res://bullet.tscn")
var characterSprite: Sprite2D
var lastShotTimer = 0.0 #Tracks when player last shot
var ammoBar
var slowmoBar
var magLabel
const SPEED = 1000

#Weapon Sprites
var gunSprite: Sprite2D
var knifeSprite: Sprite2D
var currentWeapon = "gun"

#Reload Vars
var bulletsFired = 0
var reload = false
const maxBullet = 30
const reloadTime = 2.5

#Speed of bullet and firing, and bullet comes out of barrel
const bulletSpeed = 10000
const gunOffset = Vector2(340,105) #Where bullet appears
const fireRate = 0.2 #Time in between shots

#Magazine Vars
var maxMags = 3
var magBullet = 30
var currentMag = 3

#Slow Motion Vars
var slowmoTimer = 4.0
const normalTime = 1.0
const slowmoTime = 0.2
const maxSlowmoTimer = 3.5

# Movement Code, going left-right and up-down
func _physics_process(delta):
	var direction = Input.get_axis("left", "right") 
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var directionY = Input.get_axis("up", "down")
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	look_at(get_global_mouse_position())  # Mouse sets where character aims
	
	knifeSprite.global_position = gunSprite.global_position
	knifeSprite.rotation_degrees = gunSprite.rotation_degrees
	
	if not reload:
		lastShotTimer += delta
		if Input.is_action_pressed("LMB") and lastShotTimer >= fireRate and bulletsFired < magBullet:
			if currentWeapon == "gun":
				fire()
				lastShotTimer = 0.0
			elif currentWeapon == "knife":
				knifeSwing()
				lastShotTimer = 0.5
	
	if bulletsFired >= magBullet or Input.is_action_just_pressed("reload"):
		if not reload:
			reloading()
	
	if Input.is_action_just_pressed("slowmo"):
		slowmoToggle()
		
	if Engine.time_scale == slowmoTime:
		slowmoTimer -= delta / Engine.time_scale
		if slowmoTimer <= 0:
			slowmoTimer = 0
			slowmoToggle()
	else:
		slowmoTimer += (delta / Engine.time_scale) / 4.0
		if slowmoTimer > maxSlowmoTimer:
			slowmoTimer = maxSlowmoTimer
	slowmoBar.value = slowmoTimer
	updateDisplay()
	
	if Input.is_action_just_pressed("switchWeapon"):
		weaponSwap()

func _ready():
	ammoBar = get_node("../CanvasLayer/AmmoBar")	
	ammoBar.value = maxBullet - bulletsFired
	
	slowmoBar = get_node("../CanvasLayer/SlowmoBar")
	slowmoBar.max_value = maxSlowmoTimer
	slowmoBar.value = slowmoTimer
	
	gunSprite = $SoldierGun
	knifeSprite = $SoldierKnife
	
	gunSprite.visible = true
	knifeSprite.visible = false
	
	magLabel = get_node("../CanvasLayer/Magazine")
	updateDisplay()

func fire():
	if currentWeapon == "knife":
		return
	
	if bullet and currentMag > 0:
		bulletsFired += 1
		ammoBar.value = maxBullet - bulletsFired
		var bulletInstance = bullet.instantiate()
		var spawnPosition = global_position + gunOffset.rotated(rotation)  
		
		bulletInstance.position = spawnPosition
		bulletInstance.rotation_degrees = rotation_degrees
		bulletInstance.initial_velocity = Vector2(bulletSpeed, 0).rotated(rotation)
		get_tree().get_root().call_deferred("add_child", bulletInstance)  

func knifeSwing():
	$AnimationPlayer.play("Melee Swing")

func weaponSwap():
	if currentWeapon == "gun":
		currentWeapon = "knife"
		gunSprite.visible = false
		knifeSprite.visible = true
	else:
		currentWeapon = "gun"
		gunSprite.visible = true
		knifeSprite.visible = false

func reloading():
	if currentMag > 0:
		reload = true
		var timer = Timer.new()
		timer.wait_time = reloadTime
		timer.one_shot = true
		timer.connect("timeout" , Callable(self, "_onReloadTimeout"))
		add_child(timer)
		timer.start()

func _onReloadTimeout():
	if currentMag > 0:
		bulletsFired = 0
		ammoBar.value = magBullet
		reload = false
		currentMag -= 1
		if currentMag <= 0:
			currentMag = 0
		updateDisplay()

func updateDisplay():
	ammoBar.value = magBullet - bulletsFired
	magLabel.text = "Current Mag: " + str(currentMag) if currentMag > 0 else "Out of Mags"

func slowmoToggle():
	if Engine.time_scale == normalTime and slowmoTimer > 0:
		Engine.time_scale = slowmoTime
	else:
		Engine.time_scale = normalTime
