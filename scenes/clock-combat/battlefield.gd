extends Node2D
const Character = preload("res://scenes/clock-combat/character.gd")
const Action = preload("res://scenes/clock-combat/action.gd")
const Clock = preload("res://scenes/clock-combat/clock.gd")
const Planner = preload("res://scenes/clock-combat/planner.gd")
const Party = preload("res://shared/party.gd")
const C = preload("res://shared/const.gd")
# TODO: Why is this different? Should it be?
var CombatLog = preload("res://scenes/clock-combat/combat_log.gd").new()

# A list of characters we count as enemies. None so far. 
var enemies = []

# See clock.gd
var clock: Clock

var party: Party

signal scene_change # Define the signal

# The core loop of the combat is based on the clock ticking. When it 
# ticks, if we're not already ticking, start ticking. During a tick 
# is all the interesting game design space to play with. 
var ticking: bool = false
func _on_clock_ticked():
    # We do this to keep from double ticking
    if ticking: return
    
    ticking = true
    clock.turns += 1
    await turn_time() 
    await plan_enemies()
    ticking = false

# This is called when the scene starts
func _ready() -> void:
    # Add the combat log to the scene
    CombatLog.position = Vector2(10, 650)
    add_child(CombatLog)

    # Create the clock(x, y, r, points) and add it to the scene. Everything
    # else about the clock is in clock.gd. 
    clock = Clock.new(512, 412, 100, 7)
    add_child(clock)
    # Also, we need to pay attention to the clock_event specifically
    clock.clock_event.connect(Callable(self, "_on_clock_ticked"))
    
    # Load the characters
    CombatLog.add_log_entry("Loading characters from character sheet...", Color.WHITE);
    var pcs = []
    for pc in party.pcs:
        var ch = Character.new(pc.name, pc.color, true)

        # TODO: This should be a little bit more smart/based on the character sheet more
        if pc.pc_class == C.CLASSES.WARRIOR:
            ch.add_action(Action.new("Grapple", 0, "Prevent enemy movement this turn"))
            ch.add_action(Action.new("Cleave", 3, "Attack all enemies in your zone"))
        elif pc.pc_class == C.CLASSES.WIZARD:
            ch.add_action(Action.new("Fireball", 5, "Deal all the damage to any zone"))
            ch.add_action(Action.new("Magic Missile", 1, "Deal 3 damage to any targets"))
        elif pc.pc_class == C.CLASSES.ROGUE:
            ch.add_action(Action.new("Hide", 1, "Move into stealth"))
            ch.add_action(Action.new("Stab", 1, "Move from stealth to any zone. Attack"))

        pcs.append(ch)

    # Same as above, but this would be created more in real time as we
    # create the combat, and/or loaded from a predefined list of baddies
    # TODO: Describe all the baddies in a consistent nice way (yaml?)
    CombatLog.add_log_entry("Creating minions...", Color.WHITE);
    var zombie = Character.new("Zmobie", Color.BLACK, false)
    zombie.add_action(Action.new("Bite", 1, "Attack successful. Target `infected`"))
    var necro = Character.new("Necro", Color.PURPLE, false)
    necro.add_action(Action.new("Raise", 4, "New Zombie created"))
    enemies.append(zombie)
    enemies.append(necro)
    plan_action(zombie, "Bite")
    plan_action(necro, "Raise")

    var button = Button.new()
    button.text = "Main Menu"
    button.add_theme_color_override("font_color", Color.BLACK)
    button.add_theme_font_size_override("font_size", 12)
    button.position = Vector2(15, 15)
    button.connect("pressed", Callable(self, "_on_main_menu"))
    add_child(button)
    
    for i in range(pcs.size()):
        var ch = pcs[i]
        var on_action = Callable(self, "plan_action")
        var p = Planner.new(ch, on_action)
        p.position = Vector2(400 + (200 * i), 700)
        add_child(p)

func _on_main_menu():
    scene_change.emit('menu')

# Given the name of the action, load the action and give it to the clock to plan.
# If we actually added a step, make sure to redraw the clock. 
func plan_action(ch: Character, action_name: String):
    var action = ch.get_action(action_name)
    if clock.plan_step(ch, action):
        clock.queue_redraw()


func turn_time():    
    CombatLog.add_log_entry("Turning time")
    # Remove the current list of steps. We're done with this turn.
    clock.steps.pop_front()
    # Add an empty list onto the end
    clock.steps.append([])
    # Redraw the new state. 
    clock.queue_redraw()

    # We're going to loop throw each step on the current slot
    while clock.steps[0].size() > 0:
         # first slot, first item
        var next_step = clock.steps[0][0]
        var ch: Character = next_step['character']
        var action: Action = next_step['action']
        # Pretend to do something interesting that takes a second to complete
        CombatLog.add_log_entry("\t %s used %s!" % [ch.ch_name, action.name], ch.color)
        await get_tree().create_timer(1.0).timeout

        # Remove the item from the list now that it's done and redraw the clock
        clock.steps[0].pop_front()
        clock.queue_redraw()

# For each enemy, have them take an action. 
# TODO: Build a smart AI system
func plan_enemies():
    CombatLog.add_log_entry("Enemies planning")
    for ch in enemies:
        plan_action(ch, "__random__")

func set_party(party: Party):
    self.party = party