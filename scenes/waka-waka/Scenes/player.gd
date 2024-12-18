extends CharacterBody2D

## Movement parameters
@export var max_speed: float = 200.0 # Maximum speed the character can reach
@export var acceleration: float = 500.0 # How quickly the character speeds up
@export var deceleration: float = 300.0 # How quickly the character slows down

@onready var sprite: AnimatedSprite2D = get_node("PlayerSprite")

func _ready() -> void:
    velocity = Vector2.ZERO
    motion_mode = MOTION_MODE_FLOATING

    ## Shader needs some work, but kinda works like this:
    #var shader_material = ShaderMaterial.new()
    #shader_material.shader = load("res://scenes/waka-waka/Assets/ghost_shader.gdshader")
    #sprite.material = shader_material

    sprite.play("idle")

func _physics_process(delta: float) -> void:
    var input_vector = Vector2(
        Input.get_action_strength("player_right_a") - Input.get_action_strength("player_left_a"),
        Input.get_action_strength("player_down_a") - Input.get_action_strength("player_up_a")
    )

    # Normalize input to prevent faster diagonal movement
    if input_vector.length() > 0:
        input_vector = input_vector.normalized()

    # Apply acceleration when input is given, decelerate otherwise
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)

        if velocity.x < 0.0:
            sprite.flip_h = true
        else:
            sprite.flip_h = false

        #if not sprite.is_playing() or sprite.animation == "idle":
            #sprite.play("float")
    else:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
        #if sprite.animation != "idle" or sprite.is_playing():
            #sprite.play("idle")

    # Move the character
    move_and_slide()
