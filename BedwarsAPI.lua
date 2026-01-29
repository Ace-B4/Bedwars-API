local BedwarsAPI = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function waitForKnit()
    local KnitFolder = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TS"):WaitForChild("knit")
    local Knit = require(KnitFolder).setup
    repeat task.wait() until Knit.Start and debug.getupvalue(Knit.Start, 1)
    return Knit
end
local function initializeModules()
    local KnitClient = waitForKnit()
    local GameCore = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@easy-games"):WaitForChild("game-core"):WaitForChild("out")
    return {
        BlockCpsController = KnitClient.GetController("BlockCpsController"),
        BlockPlacementController = KnitClient.GetController("BlockPlacementController"),
        CombatController = KnitClient.GetController("CombatController"),
        DamageIndicatorController = KnitClient.GetController("DamageIndicatorController"),
        FovController = KnitClient.GetController("FovController"),
        GrimReaperController = KnitClient.GetController("GrimReaperController"),
        EntityHighlightController = KnitClient.GetController("EntityHighlightController"),
        DaoController = KnitClient.GetController("DaoController"),
        KillEffectController = KnitClient.GetController("KillEffectController"),
        ProjectileController = KnitClient.GetController("ProjectileController"),
        ScytheController = KnitClient.GetController("ScytheController"),
        SprintController = KnitClient.GetController("SprintController"),
        StopwatchController = KnitClient.GetController("StopwatchController"),
        SwordController = KnitClient.GetController("SwordController"),
        ViewmodelController = KnitClient.GetController("ViewmodelController"),
        WindWalkerController = KnitClient.GetController("WindWalkerController"),
        BlockEngine = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out).BlockEngine,
        BlockPlacer = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
        ItemMeta = debug.getupvalue(require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1),
        ProjectileMeta = require(ReplicatedStorage.TS.projectile["projectile-meta"]).ProjectileMeta,
        CombatConstant = require(ReplicatedStorage.TS.combat["combat-constant"]).CombatConstant,
        AnimationUtil = require(GameCore.shared.util["animation-util"]).AnimationUtil,
        QueryUtil = require(GameCore).GameQueryUtil,
        ClientHandler = require(ReplicatedStorage.TS.remotes).default.Client,
        ClientHandlerStore = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
        ClientSyncEvents = require(LocalPlayer.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
        InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil,
        BedwarsShop = require(ReplicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
        BedwarsShopItems = require(ReplicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.ShopItems,
        GameSound = require(ReplicatedStorage.TS.sound["game-sound"]).GameSound,
    }
end
repeat task.wait() until game:IsLoaded()
local GameModules = initializeModules()
BedwarsAPI.Controllers = GameModules
BedwarsAPI.Combat = {}
function BedwarsAPI.Combat.swing()
    if GameModules.SwordController then
        GameModules.SwordController:swingSwordAtMouse()
    end
end
function BedwarsAPI.Combat.attack(entity, weapon)
    if not entity or not GameModules.SwordController then return end
    local attackData = {
        weapon = weapon or BedwarsAPI.Inventory.getSword(),
        entityInstance = entity,
        validate = {
            targetPosition = {value = entity.PrimaryPart.Position},
            selfPosition = {value = LocalPlayer.Character.HumanoidRootPart.Position}
        }
    }
    GameModules.SwordController.sendServerRequest(GameModules.SwordController, attackData)
end
function BedwarsAPI.Combat.shoot(projectileType, power)
    power = power or 1
    if GameModules.ProjectileController then
        local launchFunc = debug.getupvalue(GameModules.ProjectileController.launchProjectileWithValues, 2)
        if launchFunc then
            launchFunc(projectileType, power)
        end
    end
end
BedwarsAPI.Inventory = {}
function BedwarsAPI.Inventory.getInventory(player)
    player = player or LocalPlayer
    local success, inventory = pcall(function()
        return GameModules.InventoryUtil.getInventory(player)
    end)
    return success and inventory or {items = {}, armor = {}}
end
function BedwarsAPI.Inventory.getItem(itemName)
    local inventory = BedwarsAPI.Inventory.getInventory()
    for slot, item in pairs(inventory.items) do
        if item.itemType == itemName then
            return item, slot
        end
    end
    return nil
end
function BedwarsAPI.Inventory.getSword()
    local inventory = BedwarsAPI.Inventory.getInventory()
    local bestSword, bestSlot, bestDamage = nil, nil, 0
    for slot, item in pairs(inventory.items) do
        local swordMeta = GameModules.ItemMeta[item.itemType].sword
        if swordMeta then
            local damage = swordMeta.damage or 0
            if damage > bestDamage then
                bestSword, bestSlot, bestDamage = item, slot, damage
            end
        end
    end
    return bestSword, bestSlot
end
function BedwarsAPI.Inventory.getBow()
    local inventory = BedwarsAPI.Inventory.getInventory()
    local bestBow, bestSlot, bestDamage = nil, nil, 0
    for slot, item in pairs(inventory.items) do
        local itemMeta = GameModules.ItemMeta[item.itemType]
        if itemMeta.projectileSource then
            local bowMeta = itemMeta.projectileSource
            if bowMeta and table.find(bowMeta.ammoItemTypes, 'arrow') then
                local damage = GameModules.ProjectileMeta[bowMeta.projectileType('arrow')].combat.damage or 0
                if damage > bestDamage then
                    bestBow, bestSlot, bestDamage = item, slot, damage
                end
            end
        end
    end
    return bestBow, bestSlot
end
function BedwarsAPI.Inventory.getTool(breakType)
    local inventory = BedwarsAPI.Inventory.getInventory()
    local bestTool, bestSlot, bestDamage = nil, nil, 0
    for slot, item in pairs(inventory.items) do
        local toolMeta = GameModules.ItemMeta[item.itemType].breakBlock
        if toolMeta then
            local damage = toolMeta[breakType] or 0
            if damage > bestDamage then
                bestTool, bestSlot, bestDamage = item, slot, damage
            end
        end
    end
    return bestTool, bestSlot
end
function BedwarsAPI.Inventory.switchSlot(slot)
    if GameModules.Store then
        GameModules.Store:dispatch({
            type = 'InventorySelectHotbarSlot',
            slot = slot
        })
    end
end
function BedwarsAPI.Inventory.equipItem(item)
    local equipFunc = debug.getproto(require(ReplicatedStorage.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3)
    if equipFunc then
        equipFunc({hand = item})
    end
end
function BedwarsAPI.Inventory.dropItem()
    if GameModules.ItemDropController then
        GameModules.ItemDropController.dropItemInHand()
    end
end
function BedwarsAPI.Inventory.consumeItem()
    local consumeFunc = debug.getproto(GameModules.ConsumeController.onEnable, 1)
    if consumeFunc then
        consumeFunc()
    end
end
BedwarsAPI.Block = {}
function BedwarsAPI.Block.placeBlock(position, blockType)
    if not GameModules.BlockPlacer then return false end
    local blockPlacer = GameModules.BlockPlacer.new(GameModules.BlockEngine, blockType)
    local blockPos = GameModules.BlockController:getBlockPosition(position)
    return blockPlacer:placeBlock(blockPos)
end
function BedwarsAPI.Block.breakBlock(position)
    if not GameModules.BlockBreakController then return end
    local blockPos = GameModules.BlockController:getBlockPosition(position)
    local ClientDamageBlock = require(ReplicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client
    ClientDamageBlock:Get('DamageBlock'):CallServerAsync({
        blockRef = {blockPosition = blockPos},
        hitPosition = position,
        hitNormal = Vector3.FromNormalId(Enum.NormalId.Top)
    })
end
function BedwarsAPI.Block.getBlockAt(position)
    if not GameModules.BlockController then return nil end
    local blockPos = GameModules.BlockController:getBlockPosition(position)
    return GameModules.BlockController:getStore():getBlockAt(blockPos), blockPos
end
function BedwarsAPI.Block.isBlockBreakable(position, player)
    player = player or LocalPlayer
    local block, blockPos = BedwarsAPI.Block.getBlockAt(position)
    if not block then return false end
    return GameModules.BlockController.isBlockBreakable(GameModules.BlockController, {
        blockPosition = blockPos
    }, player)
end
BedwarsAPI.Player = {}
function BedwarsAPI.Player.getCharacter(player)
    player = player or LocalPlayer
    return player.Character
end
function BedwarsAPI.Player.getHealth(player)
    player = player or LocalPlayer
    local char = player.Character
    if not char then return 0 end
    return (char:GetAttribute('Health') or 0) + BedwarsAPI.Player.getShield(char)
end
function BedwarsAPI.Player.getMaxHealth(player)
    player = player or LocalPlayer
    local char = player.Character
    if not char then return 100 end
    return char:GetAttribute('MaxHealth') or 100
end
function BedwarsAPI.Player.getShield(character)
    local shield = 0
    for name, val in pairs(character:GetAttributes()) do
        if name:find('Shield') and type(val) == 'number' and val > 0 then
            shield = shield + val
        end
    end
    return shield
end
function BedwarsAPI.Player.getTeam(player)
    player = player or LocalPlayer
    return player:GetAttribute('Team')
end
function BedwarsAPI.Player.getKit(player)
    player = player or LocalPlayer
    return player:GetAttribute('PlayingAsKit')
end
function BedwarsAPI.Player.sprint(enabled)
    if not GameModules.SprintController then return end
    if enabled then
        GameModules.SprintController:startSprinting()
    else
        GameModules.SprintController:stopSprinting()
    end
end
function BedwarsAPI.Player.getSpeed()
    if not GameModules.SprintController then return 20 end
    local multi, increase = 0, true
    local modifiers = GameModules.SprintController:getMovementStatusModifier():getModifiers()
    for v in modifiers do
        local val = v.constantSpeedMultiplier or 0
        if val and val > math.max(multi, 1) then
            increase = false
            multi = val - (0.06 * math.round(val))
        end
    end
    for v in modifiers do
        multi = multi + math.max((v.moveSpeedMultiplier or 0) - 1, 0)
    end
    if multi > 0 and increase then
        multi = multi + 0.16 + (0.02 * math.round(multi))
    end
    return 20 * (multi + 1)
end
BedwarsAPI.Entity = {}
function BedwarsAPI.Entity.getEntitiesInRange(range, options)
    options = options or {}
    local entities = {}
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return entities end
    local localPos = localChar.HumanoidRootPart.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
            if distance <= range then
                local entity = {
                    Player = player,
                    Character = player.Character,
                    RootPart = player.Character.HumanoidRootPart,
                    Distance = distance,
                    Health = BedwarsAPI.Player.getHealth(player),
                    Team = BedwarsAPI.Player.getTeam(player)
                }
                table.insert(entities, entity)
            end
        end
    end
    return entities
end
function BedwarsAPI.Entity.getNearestEntity(range)
    local entities = BedwarsAPI.Entity.getEntitiesInRange(range or 30)
    table.sort(entities, function(a, b) return a.Distance < b.Distance end)
    return entities[1]
end
BedwarsAPI.Utility = {}
function BedwarsAPI.Utility.getMatchState()
    if GameModules.ClientHandlerStore then
        return GameModules.ClientHandlerStore:getState().Game.matchState or 0
    end
    return 0
end
function BedwarsAPI.Utility.getQueueType()
    if GameModules.ClientHandlerStore then
        return GameModules.ClientHandlerStore:getState().Game.queueType or 'bedwars_test'
    end
    return 'bedwars_test'
end
function BedwarsAPI.Utility.getItemMeta(itemType)
    return GameModules.ItemMeta[itemType]
end
function BedwarsAPI.Utility.getProjectileMeta(projectileType)
    return GameModules.ProjectileMeta[projectileType]
end
function BedwarsAPI.Utility.raycast(origin, direction, params)
    if GameModules.QueryUtil then
        return GameModules.QueryUtil:raycast(origin, direction, params)
    end
    return workspace:Raycast(origin, direction, params)
end
function BedwarsAPI.Utility.playAnimation(animationId)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid and GameModules.AnimationUtil then
        return GameModules.AnimationUtil:playAnimation(LocalPlayer, animationId)
    end
end
return BedwarsAPI