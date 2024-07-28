class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3.0
@export_category("Torch")
@export var torch_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var torch_area: Area2D = $TorchArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var is_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

# Sinaliza que coletou carne
signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): 
		GameManager.meat_counter += 1)


# A cada frame, vai reduzir o cooldown um pouquinho.
func _process(delta: float) -> void:
		# Atualizar temporizador do ataque
		if is_attacking:
				attack_cooldown -= delta
				if attack_cooldown <= 0.0:
						is_attacking = false
						is_running = false
						animation_player.play("idle")
		pass
	# Processar dano
		update_hitbox_detection(delta)
		
	# Ritual
		update_ritual(delta)
		
	#Atualizar Health Bar
		health_progress_bar.max_value = max_health
		health_progress_bar.value = health

func _physics_process(_delta: float) -> void:
		GameManager.player_position = position 
		# Obter o input vector
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
		
		# Modificar a velocidade
		var target_velocity = input_vector * speed * 100.0
		if is_attacking:
				target_velocity *= 0.25
		velocity = lerp(velocity, target_velocity, 0.15)
		move_and_slide()
		
		# Atualizar o is_running. Checa se a velocidade é maior a zero
		var was_running = is_running
		is_running = not input_vector.is_zero_approx()
		
		# Tocar Animação
		if not is_attacking:
				if was_running != is_running:
						if is_running:
								animation_player.play("run")
						else:
								animation_player.play("idle")
				# Girar Sprite
				if input_vector.x > 0:
						sprite.flip_h = false
						# Desmarcar flip_h do Sprite2D
						pass
				elif input_vector.x < 0:
						sprite.flip_h = true
						#marcar flip_h do Sprite2D
						pass
				
		# Ataque
		if Input.is_action_just_pressed("attack"):
				attack()

func update_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown	= ritual_interval
	
	# Criar ritual e atualiza a quantidade de dano
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	#adiciona ritual na cena como child do player, movendo com ele
	add_child(ritual)

func attack() -> void:
		# Se a variável de ataque for verdadeira, não pode atacar de novo.
		if is_attacking:
				return
				
		# Por enquanto o attack_up e down são ignorados, posso adicionar posteriormente
		# No exemplo ele tem attack_side_1 e attack_side_2. Como selecionar aleatoriamente, caso eu tivesse?
		# animation_player.play("attack_side_1")
		# 	pass
		animation_player.play("attack_side_1")
		
		# Configurar temporizador, tempo igual à animação
		attack_cooldown = 0.55
		#Marcar ataque
		is_attacking = true
		

func deal_damage_to_enemies() -> void:
	if torch_area == null:
		print("Torch area is not set correctly.")
		return
	
	var bodies = torch_area.get_overlapping_bodies()
	for body in bodies: 
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction= Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			# Para o ataque afetar a área da tocha, checar se o dot é maior que 0.4
			
			if enemy && dot_product >= 0.01:
				enemy.damage(torch_damage)

func update_hitbox_detection(delta: float) -> void:
	#Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	#Frequência (2x por segundo)
	hitbox_cooldown = 0.5
	#Hitbox Area
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			@warning_ignore("unused_variable")
			var enemy: Enemy = body
			var damage_amount = 2
			damage(damage_amount)
	pass

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano igual a ", amount, ". A vida total é de ", health, "/", max_health)
	
	# Piscar o player
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	#Processar morte
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player morreu!")
	queue_free()

# Regenerar vida!
func heal(amount: int) -> int:
		health += amount
		if health > max_health:
			health = max_health
		print("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health)
		return health
		
