extends Node2D
const PC = preload("res://shared/pc.gd")
const Party = preload("res://shared/party.gd")
const C = preload("res://shared/const.gd")

var current_scene: Node = null

var party: Party

# This dict allows us to reference scenes by name. It does load all of them
# before we need them. If this becomes a performance concern, we'll need to
# figure out how to lazy load them.
var scenes = {
    "clock-combat": preload("res://scenes/clock-combat/combat.tscn"),
    "waka-waka": preload("res://scenes/waka-waka/Scenes/main.tscn"),
    "menu": preload("res://scenes/main-menu/menu.tscn"),
}


func _ready() -> void:
    # TODO: Load this from a save file in some way shape or form
    var z = PC.new("Zypher", C.CLASSES.WIZARD, Color.BLUE)
    z.smarts = 4
    z.stuff.append(C.EQUIPMENT.WAND_OF_FIREBALLS)
    z.stuff.append(C.EQUIPMENT.MYSTIC_ROBES)

    var w = PC.new("Wicks", C.CLASSES.ROGUE, Color.GREEN)
    w.speed = 3
    w.stealth = 4
    w.strength = 1
    w.stuff.append(C.EQUIPMENT.THROWING_DAGGERS)
    w.stuff.append(C.EQUIPMENT.HIDE_ARMOR)
    w.stuff.append(C.EQUIPMENT.LOCKPICKS)

    var v = PC.new("Victor", C.CLASSES.WARRIOR, Color.RED)
    v.strength = 5
    v.stuff.append(C.EQUIPMENT.GREATAXE)

    party = Party.new()
    party.add_pc(z)
    party.add_pc(w)
    party.add_pc(v)

    # By default, we load the menu scene
    change_scene("menu")

# This function changes the scene. But the other important thing it does it
# register a listener on the new scene for further scene changes.
func change_scene(scene_name: String):

    # Safety check to try to make sure we are loading a real scene
    if not scenes.has(scene_name):
        print("Trying to switch to an invalid scene")
        return

    # If there's a scene already, we should remove it
    if current_scene:
        current_scene.queue_free()

    # Create a new instance of the scene. If/when we get to passing information
    # between scenes, this is likely the place we hook it in.
    var scene = scenes[scene_name].instantiate()

    # If the scene wants to channge, we listen for this event on each one
    # Note: The signal needs to come from the root node of the scene
    if scene.has_signal("scene_change"):
        scene.connect("scene_change", Callable(self, "change_scene"))

    if scene.has_method("set_party"):
        scene.set_party(party)

    # Add the scene to the node. Fade in and transitions likely start here.
    add_child(scene)
    current_scene = scene
