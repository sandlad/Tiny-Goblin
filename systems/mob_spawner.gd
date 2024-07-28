class_name MobSpawner
extends Node2D

#Lista de criaturas que podemos spawnar
@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0

# Cálculo para criar inimigos
func _process(delta: float):
	# Ignorar se GameOver
	if GameManager.is_game_over: return
	# Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0: return
		
	# Frequência: Monstros por minuto
	# 60 monstros/min = 1 monstro / seg
	# 120 monstros/min = 2 monstros / seg
	# Intervalo em segundos entre monstros => 60 / frequência
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se o ponto é válido
		# Perguntar pro jogo se esse ponto tem colisão; Acessar o espaço físico do jogo
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	# get_world_2d pega o mundo 2D do jogo, e direct_space_state é o estado dele.
	# O world_state tem a informação que quero; sabe se tem a colisão ou não
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	# Se eu quiser que o spawner só cheque a barreira, Ir em Collision e mexer na máscara.
	parameters.collision_mask = 0b1000 # O bit é lido de trás pra frente.
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	# Instanciar uma criatura aleatória
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
	# - Pegar criatura aleatória
	# - Pegar ponto aleatório
	# - Instanciar cena
	# - Colocar na posição
	
	pass
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf() 
	# Random float, retorna valor decimal aleatório entre 0 e 1
	# Usa o global_position ao invés de position para não depender da posição local
	return path_follow_2d.global_position

