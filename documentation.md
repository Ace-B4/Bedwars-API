<h1 align="center">BEDWARS API</h1>
<h3 align="center">Easy to use API for Roblox Bedwars</h3>

<p align="center">
  <a href="https://github.com/Ace-B4/Bedwars-API/issues">
    <img src="https://img.shields.io/github/issues/Ace-B4/Bedwars-API?style=for-the-badge&color=f85149&logoColor=white&labelColor=0d1117" alt="Issues"/>
  </a>
  <a href="Language">
    <img src="https://img.shields.io/badge/Language-Lua-blue?style=for-the-badge&logoColor=white&labelColor=0d1117" alt="Lua"/>
  </a>
</p>


<p align="center">
  <strong>Designed for utility development</strong><br>
  Brought to you by Raven B4
</p>

---

## Installation

```lua
-- Load API
local BedwarsAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ace-B4/Bedwars-API/main/BedwarsAPI.lua"))()
```

> `IMPORTANT`  Place this above all your api calls.

---

## Quick Start (30 seconds)

```lua
local API = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ace-B4/Bedwars-API/main/BedwarsAPI.lua"))()

-- Wait until match is active
repeat task.wait() until API.Utility.getMatchState() == 2

-- Basic combat loop example: target nearest enemy
while task.wait(0.4) do
    local target = API.Entity.getNearestEntity(28)
    if target and target.Team ~= API.Player.getTeam() then
        API.Combat.attack(target.Character)
    end
end
```

---

## API Modules Overview

| Module       | Primary Purpose                              | Most Commonly Used Methods                       |
|--------------|----------------------------------------------|--------------------------------------------------|
| Combat       | Weapon usage and projectile attacks          | .swing(), .attack(entity), .shoot(type, power)   |
| Inventory    | Item lookup, equipping, tool selection       | .getSword(), .getTool(breakType), .switchSlot(n) |
| Block        | Block placement, destruction and querying    | .placeBlock(pos, type), .breakBlock(pos)         |
| Player       | Player state, movement, and attributes       | .getTeam(), .getKit(), .sprint(enabled)          |
| Entity       | Nearby player detection and filtering        | .getNearestEntity(range), .getEntitiesInRange()  |
| Utility      | Game state, raycasting, metadata access      | .getMatchState(), .raycast(), .getItemMeta()     |
| Controllers  | Direct access to all game controllers        | .SwordController, .Store, .Knit                  |

---

## Complete API Reference

### Combat Module

#### `API.Combat.swing()`
Swings the currently held sword.

**Parameters:** None  
**Returns:** `void`

**Example:**
```lua
API.Combat.swing()
```

---

#### `API.Combat.attack(entity, weapon?)`
Attacks a specified entity.

**Parameters:**
- `entity` (**Model**) - The character model to attack
- `weapon` (**Tool?**) - Optional weapon tool (defaults to best sword)

**Returns:** `void`

**Example:**
```lua
local target = workspace.SomePlayer
API.Combat.attack(target)

-- With specific weapon
local sword = API.Inventory.getSword()
API.Combat.attack(target, sword.tool)
```

---

#### `API.Combat.shoot(projectileType, power?)`
Shoots a projectile (arrow, snowball, fireball, etc.)

**Parameters:**
- `projectileType` (**string**) - Type of projectile ("arrow", "snowball", "fireball", etc.)
- `power` (**number?**) - Power of the shot (0-1, default: 1)

**Returns:** `void`

**Example:**
```lua
-- Full power arrow
API.Combat.shoot("arrow", 1)

-- Half power snowball
API.Combat.shoot("snowball", 0.5)

-- Full power fireball
API.Combat.shoot("fireball", 1)
```

---

### Inventory Module

#### `API.Inventory.getInventory(player?)`
Gets the inventory of a player.

**Parameters:**
- `player` (**Player?**) - The player to get inventory from (default: LocalPlayer)

**Returns:** **InventoryData**

**InventoryData Structure:**
```lua
{
    items = {
        [slot: number] = ItemData
    },
    armor = {
        [slot: number] = ItemData
    }
}
```

**Example:**
```lua
local inv = API.Inventory.getInventory()
print("Total items:", #inv.items)

-- Get another player's inventory
local enemyInv = API.Inventory.getInventory(game.Players.SomePlayer)
```

---

#### `API.Inventory.getItem(itemName)`
Finds a specific item in your inventory by name.

**Parameters:**
- `itemName` (**string**) - The item type to search for

**Returns:** 
- **ItemData** - Item data
- **number** - Slot number

**ItemData Structure:**
```lua
{
    itemType = string,      -- e.g., "wool_white", "iron_sword"
    amount = number,        -- Stack size
    tool = Tool?            -- Tool instance if equipped
}
```

**Example:**
```lua
local wool, slot = API.Inventory.getItem("wool_white")
if wool then
    print("Found", wool.amount, "wool in slot", slot)
end

-- Check for sword
local sword, slot = API.Inventory.getItem("emerald_sword")
```

---

#### `API.Inventory.getSword()`
Gets the best sword in your inventory based on damage.

**Parameters:** None

**Returns:**
- **ItemData** - Sword item data
- **number** - Slot number

**Example:**
```lua
local sword, slot = API.Inventory.getSword()
if sword then
    print("Best sword:", sword.itemType, "| Damage:", 
          API.Utility.getItemMeta(sword.itemType).sword.damage)
end
```

---

#### `API.Inventory.getBow()`
Gets the best bow in your inventory based on damage.

**Parameters:** None

**Returns:**
- **ItemData** - Bow item data
- **number** - Slot number

**Example:**
```lua
local bow, slot = API.Inventory.getBow()
if bow then
    API.Inventory.switchSlot(slot)
    API.Combat.shoot("arrow", 1)
end
```

---

#### `API.Inventory.getTool(breakType)`
Gets the best tool for a specific break type.

**Parameters:**
- `breakType` (**string**) - Type of block material ("wood", "stone", "wool")

**Returns:**
- **ItemData** - Tool item data
- **number** - Slot number

**Example:**
```lua
local axe, slot = API.Inventory.getTool("wood")
local pickaxe, slot = API.Inventory.getTool("stone")
local shears, slot = API.Inventory.getTool("wool")
```

---

#### `API.Inventory.switchSlot(slot)`
Switches to a specific hotbar slot.

**Parameters:**
- `slot` (**number**) - Slot number (0-8, where 0 is first slot)

**Returns:** `void`

**Example:**
```lua
API.Inventory.switchSlot(0)  -- First slot
API.Inventory.switchSlot(8)  -- Last slot
```

---

#### `API.Inventory.equipItem(item)`
Equips a specific item/tool.

**Parameters:**
- `item` (**Tool**) - The tool instance to equip

**Returns:** `void`

**Example:**
```lua
local sword = API.Inventory.getSword()
if sword and sword.tool then
    API.Inventory.equipItem(sword.tool)
end
```

---

#### `API.Inventory.dropItem()`
Drops the currently held item.

**Parameters:** None  
**Returns:** `void`

**Example:**
```lua
API.Inventory.dropItem()
```

---

#### `API.Inventory.consumeItem()`
Consumes the currently held item (eating/drinking).

**Parameters:** None  
**Returns:** `void`

**Example:**
```lua
-- Hold an apple or potion, then:
API.Inventory.consumeItem()
```

---

### Block Module

#### `API.Block.placeBlock(position, blockType)`
Places a block at a specific world position.

**Parameters:**
- `position` (**Vector3**) - World position to place block
- `blockType` (**string**) - Type of block to place (e.g., "wool_white", "wood_plank", "stone")

**Returns:** **boolean** - Success status

**Example:**
```lua
local pos = Vector3.new(100, 50, 100)
local success = API.Block.placeBlock(pos, "wool_white")

-- Place multiple blocks
for i = 0, 10 do
    API.Block.placeBlock(Vector3.new(100 + i*3, 50, 100), "wood_plank")
    task.wait(0.1)
end
```

---

#### `API.Block.breakBlock(position)`
Breaks a block at a specific world position.

**Parameters:**
- `position` (**Vector3**) - World position of block to break

**Returns:** `void`

**Example:**
```lua
local blockPos = Vector3.new(100, 50, 100)
API.Block.breakBlock(blockPos)
```

---

#### `API.Block.getBlockAt(position)`
Gets the block instance at a specific position.

**Parameters:**
- `position` (**Vector3**) - World position to check

**Returns:**
- **Instance?** - Block instance (nil if no block)
- **Vector3** - Exact block grid position

**Example:**
```lua
local block, blockPos = API.Block.getBlockAt(Vector3.new(100, 50, 100))
if block then
    print("Block:", block.Name)
    print("Position:", blockPos)
    print("Health:", block:GetAttribute("Health"))
end
```

---

#### `API.Block.isBlockBreakable(position, player?)`
Checks if a block can be broken by a player.

**Parameters:**
- `position` (**Vector3**) - World position of block
- `player` (**Player?**) - Player to check permissions for (default: LocalPlayer)

**Returns:** **boolean** - Whether the block can be broken

**Example:**
```lua
local pos = Vector3.new(100, 50, 100)
if API.Block.isBlockBreakable(pos) then
    API.Block.breakBlock(pos)
else
    print("Cannot break this block (protected or bed)")
end
```

---

### Player Module

#### `API.Player.getCharacter(player?)`
Gets a player's character model.

**Parameters:**
- `player` (**Player?**) - The player (default: LocalPlayer)

**Returns:** **Model?** - Character model

**Example:**
```lua
local char = API.Player.getCharacter()
print("Character:", char.Name)
```

---

#### `API.Player.getHealth(player?)`
Gets a player's current health including shields.

**Parameters:**
- `player` (**Player?**) - The player (default: LocalPlayer)

**Returns:** **number** - Current health + shield

**Example:**
```lua
local health = API.Player.getHealth()
local maxHealth = API.Player.getMaxHealth()
print(string.format("HP: %d/%d (%.0f%%)", health, maxHealth, (health/maxHealth)*100))
```

---

#### `API.Player.getMaxHealth(player?)`
Gets a player's maximum health.

**Parameters:**
- `player` (**Player?**) - The player (default: LocalPlayer)

**Returns:** **number** - Maximum health (default 100)

**Example:**
```lua
local maxHp = API.Player.getMaxHealth()
```

---

#### `API.Player.getShield(character)`
Gets the total shield amount of a character.

**Parameters:**
- `character` (**Model**) - The character model

**Returns:** **number** - Total shield points

**Example:**
```lua
local char = API.Player.getCharacter()
local shield = API.Player.getShield(char)
print("Shield:", shield)
```

---

#### `API.Player.getTeam(player?)`
Gets a player's team.

**Parameters:**
- `player` (**Player?**) - The player (default: LocalPlayer)

**Returns:** **string** - Team identifier

**Example:**
```lua
local myTeam = API.Player.getTeam()
local enemyTeam = API.Player.getTeam(enemyPlayer)

if myTeam ~= enemyTeam then
    print("Enemy detected!")
end
```

---

#### `API.Player.getKit(player?)`
Gets a player's active kit.

**Parameters:**
- `player` (**Player?**) - The player (default: LocalPlayer)

**Returns:** **string** - Kit name (e.g., "barbarian", "archer", "mage")

**Example:**
```lua
local kit = API.Player.getKit()
print("Playing as:", kit)

-- Check enemy kit
local enemy = game.Players.SomePlayer
if API.Player.getKit(enemy) == "hannah" then
    print("Watch out! Enemy has Hannah kit")
end
```

---

#### `API.Player.sprint(enabled)`
Toggles sprinting.

**Parameters:**
- `enabled` (**boolean**) - Whether to enable sprint

**Returns:** `void`

**Example:**
```lua
API.Player.sprint(true)   -- Start sprinting
task.wait(2)
API.Player.sprint(false)  -- Stop sprinting
```

---

#### `API.Player.getSpeed()`
Gets the player's current movement speed in studs/second.

**Parameters:** None

**Returns:** **number** - Movement speed

**Example:**
```lua
local speed = API.Player.getSpeed()
print("Speed:", speed, "studs/s")

-- Base speed is 20, sprint is usually ~24-26
if speed > 22 then
    print("Currently sprinting or has speed boost")
end
```

---

### Entity Module

#### `API.Entity.getEntitiesInRange(range, options?)`
Gets all entities (players) within a specified range.

**Parameters:**
- `range` (**number**) - Range in studs
- `options` (**table?**) - Optional filter options

**Returns:** **EntityData[]** - Array of entity data

**EntityData Structure:**
```lua
{
    Player = Player,              -- Player instance
    Character = Model,            -- Character model
    RootPart = BasePart,         -- HumanoidRootPart
    Distance = number,           -- Distance from you
    Health = number,             -- Current health + shield
    Team = string                -- Team identifier
}
```

**Example:**
```lua
local entities = API.Entity.getEntitiesInRange(30)

for _, entity in ipairs(entities) do
    print(string.format("%s | HP: %d | Distance: %.1f", 
        entity.Player.Name, entity.Health, entity.Distance))
end

-- Filter to enemies only
local myTeam = API.Player.getTeam()
for _, entity in ipairs(entities) do
    if entity.Team ~= myTeam then
        print("Enemy:", entity.Player.Name)
    end
end
```

---

#### `API.Entity.getNearestEntity(range?)`
Gets the nearest entity within range.

**Parameters:**
- `range` (**number?**) - Range in studs (default: 30)

**Returns:** **EntityData?** - Nearest entity data (nil if none found)

**Example:**
```lua
local nearest = API.Entity.getNearestEntity(50)
if nearest then
    print("Nearest player:", nearest.Player.Name, "at", nearest.Distance, "studs")

    -- Attack if enemy
    if nearest.Team ~= API.Player.getTeam() then
        API.Combat.attack(nearest.Character)
    end
end
```

---

### Utility Module

#### `API.Utility.getMatchState()`
Gets the current match state.

**Parameters:** None

**Returns:** **number** - Match state code

**Match States:**
- `0` = Lobby (waiting for players)
- `1` = Starting (countdown)
- `2` = Playing (game in progress)
- `3` = Ended (game finished)

**Example:**
```lua
local state = API.Utility.getMatchState()

if state == 0 then
    print("Waiting in lobby...")
elseif state == 1 then
    print("Game starting soon!")
elseif state == 2 then
    print("Game in progress")
else
    print("Game ended")
end

-- Wait for game to start
repeat task.wait() until API.Utility.getMatchState() == 2
print("Game started!")
```

---

#### `API.Utility.getQueueType()`
Gets the current queue/game mode.

**Parameters:** None

**Returns:** **string** - Queue type identifier

**Common Queue Types:**
- `"bedwars_test"` - Practice mode
- `"bedwars_to_two"` - 2v2v2v2
- `"bedwars_to_four"` - 4v4v4v4
- `"bedwars_lucky_break"` - Lucky Block mode

**Example:**
```lua
local queue = API.Utility.getQueueType()
print("Playing:", queue)

if queue:find("lucky") then
    print("Lucky Block mode!")
end
```

---

#### `API.Utility.getItemMeta(itemType)`
Gets metadata for an item type. **This is the most detailed function.**

**Parameters:**
- `itemType` (**string**) - Item type name (e.g., "emerald_sword", "wood_plank", "wool_white")

**Returns:** **ItemMetadata** - Complete item metadata

**ItemMetadata Structure (All Possible Properties):**
```lua
{
    -- Basic Properties (all items)
    itemType = string,              -- "emerald_sword", "wool_white", etc.
    image = string,                 -- Asset ID for item icon
    displayName = string,           -- Human-readable name

    -- Sword Properties (if item is a sword)
    sword = {
        damage = number,            -- Base damage (e.g., 55 for emerald)
        knockbackMultiplier = number, -- Knockback strength
        attackSpeed = number,       -- Attack cooldown
        chargedAttack = {           -- Charged attack properties
            bonusDamage = number,
            chargeTime = number,
            walkSpeedMultiplier = number
        }
    },

    -- Projectile Properties (if item shoots projectiles)
    projectileSource = {
        projectileType = function(ammo: string) -> string,
        ammoItemTypes = string[],   -- e.g., {"arrow"}
        walkSpeedMultiplier = number,
        maxStrengthChargeSec = number,
        thirdPerson = {
            fireAnimation = number,
            holdAnimation = number
        },
        firstPerson = {
            fireAnimation = number
        }
    },

    -- Armor Properties (if item is armor)
    armor = {
        damageReductionMultiplier = number,  -- Damage reduction (e.g., 0.24 = 24% reduction)
        slot = number                        -- Armor slot (0=helmet, 1=chestplate, 2=boots)
    },

    -- Block Properties (if item is a block)
    block = {
        breakType = string,         -- "wool", "wood", "stone"
        placeSound = {
            soundId = string,
            volume = number,
            pitch = number
        },
        breakSound = { ... },
        health = number,            -- Block health
        disableInventoryPickup = boolean,
        seeThrough = boolean       -- Is block transparent
    },

    -- Tool/Break Properties (if item breaks blocks)
    breakBlock = {
        wood = number,              -- Break speed for wood (higher = faster)
        stone = number,             -- Break speed for stone
        wool = number               -- Break speed for wool
    },

    -- Consumable Properties (if item can be consumed)
    consumable = {
        consumeTime = number,       -- Time to consume in seconds
        statusEffect = {
            statusEffectType = string,  -- "speed", "heal", "jump_boost", etc.
            duration = number,          -- Duration in seconds
            amplifier = number          -- Effect strength
        },
        soundOverride = string
    },

    -- Stackable Properties
    maxStackSize = number,          -- Maximum stack size (e.g., 64 for blocks)

    -- Shop Properties
    sharingDisabled = boolean,
    disableDropping = boolean,
    keepOnDeath = boolean,

    -- Misc Properties
    firstPerson = {
        verticalOffset = number
    }
}
```

**Example Usage:**
```lua
-- Sword metadata
local emeraldMeta = API.Utility.getItemMeta("emerald_sword")
print("Emerald Sword Damage:", emeraldMeta.sword.damage)  -- 55
print("Knockback:", emeraldMeta.sword.knockbackMultiplier)

-- Compare swords
local woodMeta = API.Utility.getItemMeta("wood_sword")
local ironMeta = API.Utility.getItemMeta("iron_sword")
local diamondMeta = API.Utility.getItemMeta("diamond_sword")

print("Wood sword damage:", woodMeta.sword.damage)      -- 20
print("Iron sword damage:", ironMeta.sword.damage)      -- 30
print("Diamond sword damage:", diamondMeta.sword.damage) -- 35

-- Armor metadata
local armorMeta = API.Utility.getItemMeta("emerald_chestplate")
print("Damage reduction:", armorMeta.armor.damageReductionMultiplier * 100, "%")
print("Armor slot:", armorMeta.armor.slot)  -- 1 (chestplate)

-- Block metadata
local blockMeta = API.Utility.getItemMeta("stone")
print("Break type:", blockMeta.block.breakType)  -- "stone"
print("Block health:", blockMeta.block.health)

-- Tool metadata
local axeMeta = API.Utility.getItemMeta("wood_axe")
print("Wood breaking power:", axeMeta.breakBlock.wood)  -- High
print("Stone breaking power:", axeMeta.breakBlock.stone) -- Low

-- Consumable metadata
local appleMeta = API.Utility.getItemMeta("apple")
print("Consume time:", appleMeta.consumable.consumeTime, "seconds")
if appleMeta.consumable.statusEffect then
    print("Effect:", appleMeta.consumable.statusEffect.statusEffectType)
    print("Duration:", appleMeta.consumable.statusEffect.duration, "seconds")
end

-- Check if item can break specific block type
local pickaxe = API.Utility.getItemMeta("wood_pickaxe")
if pickaxe.breakBlock and pickaxe.breakBlock.stone then
    print("This tool can break stone!")
end
```

**Common Item Types:**
```lua
-- Swords
"wood_sword", "stone_sword", "iron_sword", "diamond_sword", "emerald_sword", "rageblade"

-- Armor (helmets: _0, chestplates: _1, boots: _2)
"leather_helmet", "leather_chestplate", "leather_boots"
"iron_helmet", "iron_chestplate", "iron_boots"
"diamond_helmet", "diamond_chestplate", "diamond_boots"
"emerald_helmet", "emerald_chestplate", "emerald_boots"

-- Bows
"wood_bow", "crossbow", "tactical_crossbow"

-- Tools
"wood_axe", "stone_axe", "iron_axe", "diamond_axe"
"wood_pickaxe", "stone_pickaxe", "iron_pickaxe", "diamond_pickaxe"
"shears"

-- Blocks
"wool_white", "wool_blue", "wool_red", "wool_green", "wool_yellow", "wool_pink", "wool_gray", "wool_orange"
"wood_plank", "wood_plank_birch", "wood_plank_spruce", "wood_plank_oak"
"stone", "stone_brick", "sandstone", "slate_brick"
"glass", "glass_blue", "glass_red", "glass_green"
"clay", "clay_blue", "clay_red", "clay_green"

-- Consumables
"apple", "golden_apple", "speed_potion", "invisibility_potion", "jump_boost_potion"

-- Projectiles
"arrow", "iron_arrow", "snowball", "fireball", "wood_dao"

-- Special Items
"bed", "emerald", "diamond", "iron", "telepearl", "bridge_egg"
```

---

#### `API.Utility.getProjectileMeta(projectileType)`
Gets metadata for a projectile type.

**Parameters:**
- `projectileType` (**string**) - Projectile type name (e.g., "arrow", "fireball")

**Returns:** **ProjectileMetadata** - Complete projectile metadata

**ProjectileMetadata Structure:**
```lua
{
    projectile = {
        projectileType = string,    -- "arrow", "fireball", etc.
        heightOffset = number,      -- Vertical spawn offset
        launchSound = {
            soundId = string,
            volume = number,
            pitch = number
        },
        hitSound = { ... }
    },

    combat = {
        damage = number,            -- Projectile damage
        knockbackMultiplier = number,
        projectileType = string
    },

    -- Physics properties
    gravity = number,               -- Gravity multiplier
    friction = number,              -- Air resistance
}
```

**Example:**
```lua
local arrowMeta = API.Utility.getProjectileMeta("arrow")
print("Arrow damage:", arrowMeta.combat.damage)
print("Arrow gravity:", arrowMeta.gravity)

local fireballMeta = API.Utility.getProjectileMeta("fireball")
print("Fireball damage:", fireballMeta.combat.damage)
```

---

#### `API.Utility.raycast(origin, direction, params?)`
Performs a raycast from origin in a direction.

**Parameters:**
- `origin` (**Vector3**) - Starting position
- `direction` (**Vector3**) - Direction and maximum distance
- `params` (**RaycastParams?**) - Optional raycast parameters

**Returns:** **RaycastResult?** - Raycast result (nil if nothing hit)

**RaycastResult Structure:**
```lua
{
    Instance = Instance,     -- Part that was hit
    Position = Vector3,      -- Hit position
    Normal = Vector3,        -- Surface normal
    Material = EnumItem,     -- Material of hit surface
    Distance = number        -- Distance to hit
}
```

**Example:**
```lua
-- Raycast from camera
local camera = workspace.CurrentCamera
local origin = camera.CFrame.Position
local direction = camera.CFrame.LookVector * 200

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}

local result = API.Utility.raycast(origin, direction, params)
if result then
    print("Hit:", result.Instance.Name)
    print("Position:", result.Position)
    print("Distance:", result.Distance, "studs")
end

-- Raycast downwards to check ground
local char = API.Player.getCharacter()
if char then
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local downcast = API.Utility.raycast(
        rootPart.Position,
        Vector3.new(0, -10, 0)
    )

    if downcast then
        print("Ground distance:", downcast.Distance)
    end
end
```

---

#### `API.Utility.playAnimation(animationId)`
Plays an animation on the local character.

**Parameters:**
- `animationId` (**number** or **string**) - Animation asset ID

**Returns:** **AnimationTrack?** - Animation track instance

**Example:**
```lua
local anim = API.Utility.playAnimation(123456789)
if anim then
    anim:Play()
    task.wait(2)
    anim:Stop()
end
```

---

### Controllers Module

#### `API.Controllers`
Direct access to all game controllers and modules.

**Available Controllers:**

**Parameters:** None (property access)

**Returns:** **table** - Table containing all game modules

**Available Controllers:**
```lua
{
    -- Core Controllers
    AbilityController,        -- Kit abilities management
    SwordController,          -- Sword combat controller
    ProjectileController,     -- Projectile shooting
    SprintController,         -- Sprint management
    InventoryController,      -- Inventory management
    BlockBreakController,     -- Block breaking
    ItemDropController,       -- Item dropping
    ConsumeController,        -- Item consumption

    -- Block System
    BlockController,          -- Block engine controller
    BlockEngine,             -- Client block engine
    BlockPlacer,             -- Block placement system

    -- Utilities
    ItemMeta,                -- Item metadata table
    ProjectileMeta,          -- Projectile metadata
    CombatConstant,          -- Combat constants
    KnockbackUtil,           -- Knockback calculations
    AnimationUtil,           -- Animation player
    QueryUtil,               -- Raycast utilities
    InventoryUtil,           -- Inventory utilities

    -- Network
    Client,                  -- Client remotes

    -- State
    Store,                   -- Redux store
    Knit                     -- Knit framework
}
```

**Example Usage:**

```lua
-- Access SwordController directly
local swordController = API.Controllers.SwordController
print("Sword Controller:", swordController)

-- Use BlockController
local blockController = API.Controllers.BlockController
local blockPos = blockController:getBlockPosition(Vector3.new(0, 50, 0))
print("Block Position:", blockPos)

-- Access Store for game state
local gameState = API.Controllers.Store:getState()
print("Match State:", gameState.Game.matchState)
print("Queue Type:", gameState.Game.queueType)

-- Use KnockbackUtil for custom calculations
local knockback = API.Controllers.KnockbackUtil
-- Custom knockback calculations

-- Access all item metadata
local allItems = API.Controllers.ItemMeta
for itemName, data in pairs(allItems) do
    print("Item:", itemName)
end

-- Use Knit to access other services
local knit = API.Controllers.Knit
-- Access any Knit controller

-- Play animations directly
API.Controllers.AnimationUtil:playAnimation(LocalPlayer, 12345)

-- Access inventory utilities
local inventory = API.Controllers.InventoryUtil.getInventory(LocalPlayer)
```

---

## Type Definitions

### Core Types

```lua
-- Basic types
type Vector3 = {X: number, Y: number, Z: number}
type Player = Instance  -- Roblox Player instance
type Model = Instance   -- Roblox Model instance
type Tool = Instance    -- Roblox Tool instance

-- API Types
type ItemData = {
    itemType: string,
    amount: number,
    tool: Tool?
}

type InventoryData = {
    items: {[number]: ItemData},
    armor: {[number]: ItemData}
}

type EntityData = {
    Player: Player,
    Character: Model,
    RootPart: BasePart,
    Distance: number,
    Health: number,
    Team: string
}

type RaycastResult = {
    Instance: Instance,
    Position: Vector3,
    Normal: Vector3,
    Material: EnumItem,
    Distance: number
}
```

### Item Metadata Types

```lua
type SwordMetadata = {
    damage: number,
    knockbackMultiplier: number?,
    attackSpeed: number?,
    chargedAttack: {
        bonusDamage: number,
        chargeTime: number,
        walkSpeedMultiplier: number
    }?
}

type ArmorMetadata = {
    damageReductionMultiplier: number,
    slot: number  -- 0=helmet, 1=chestplate, 2=boots
}

type BlockMetadata = {
    breakType: string,  -- "wool" | "wood" | "stone"
    placeSound: SoundMetadata,
    breakSound: SoundMetadata,
    health: number,
    disableInventoryPickup: boolean?,
    seeThrough: boolean?
}

type BreakBlockMetadata = {
    wood: number?,
    stone: number?,
    wool: number?
}

type ConsumableMetadata = {
    consumeTime: number,
    statusEffect: {
        statusEffectType: string,
        duration: number,
        amplifier: number
    }?,
    soundOverride: string?
}

type ProjectileSourceMetadata = {
    projectileType: (ammo: string) -> string,
    ammoItemTypes: {string},
    walkSpeedMultiplier: number?,
    maxStrengthChargeSec: number?,
    thirdPerson: AnimationMetadata?,
    firstPerson: AnimationMetadata?
}

type ItemMetadata = {
    itemType: string,
    image: string?,
    displayName: string?,
    sword: SwordMetadata?,
    armor: ArmorMetadata?,
    block: BlockMetadata?,
    breakBlock: BreakBlockMetadata?,
    consumable: ConsumableMetadata?,
    projectileSource: ProjectileSourceMetadata?,
    maxStackSize: number?,
    sharingDisabled: boolean?,
    disableDropping: boolean?,
    keepOnDeath: boolean?
}
```

---

## Important Notes

- **Educational purposes only** - This API is for educational purposes only
- **Current working as of January 28, 2026** - API is 1:1 the same as the game controllers, can change with updates.

---

## Common Mistakes

### Wrong
```lua
-- Don't pass player name as string
API.Player.getHealth("PlayerName")  -- ERROR

-- Don't use non-existent item types
API.Inventory.getItem("super_sword")  -- Returns nil

-- Don't forget to check if entity exists
local target = API.Entity.getNearestEntity(20)
API.Combat.attack(target.Character)  -- May error if target is nil
```

### Correct
```lua
-- Pass Player instance
API.Player.getHealth(game.Players.PlayerName)

-- Check valid item types
local item = API.Inventory.getItem("emerald_sword")
if item then
    print("Found sword!")
end

-- Always check for nil
local target = API.Entity.getNearestEntity(20)
if target then
    API.Combat.attack(target.Character)
end
```


<p align="center">
  <sub> &copy; Raven B4 all rights reserved</sub>
</p>
