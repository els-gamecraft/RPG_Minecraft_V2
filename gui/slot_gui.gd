extends Button

@onready var backroundSprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://inventory/playerInventory.tres")

var itemStackGui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	itemStackGui = isg
	backroundSprite.frame = 1
	container.add_child(itemStackGui)
	
	if !itemStackGui.inventorySlot || inventory.slots[index] == itemStackGui.inventorySlot:
		return
	
	inventory.insertSlot(index, itemStackGui.inventorySlot)
	
func takeItem():
	var item = itemStackGui
	
	inventory.removeSlot(itemStackGui.inventorySlot)
	
	container.remove_child(itemStackGui)
	itemStackGui = null
	backroundSprite.frame = 0
	
	return item
	

func isEmpty():
	return !itemStackGui
