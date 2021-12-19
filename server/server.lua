-- Variables
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local frozen = false
local permissions = {
    ['kill'] = 'god',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin'
}

-- Get Dealers
ESX.RegisterServerCallback('test:getdealers', function(source, cb)
    -- cb(exports['pepe-drugs']:GetDealers())
    cb({})
end)

-- Get Players
ESX.RegisterServerCallback('test:getplayers', function(source, cb) -- WORKS
    local players = {}
    for k, v in pairs(ESX.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = ESX.GetPlayerFromId(v)
        players[#players+1] = {
            name = ped.get('firstName') .. ' ' .. ped.get('lastName') .. ' | (' .. GetPlayerName(v) .. ')',
            -- name = '(' .. GetPlayerName(v) .. ')',
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.get('firstName') .. ' ' .. ped.get('lastName'),
            -- citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.source),
            sourceplayer= ped.source

        }
    end
        -- Sort players list by source ID (1,2,3,4,5, etc) --
        table.sort(players, function(a, b)
            return a.id < b.id
        end)
        ------
    cb(players)
end)

ESX.RegisterServerCallback('qb-admin:server:getrank', function(source, cb)
    local src = source
    if IsPlayerAceAllowed(src, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions

local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Events

RegisterNetEvent('qb-admin:server:GetPlayersForBlips', function()
    local src = source
    local players = {}
    for k, v in pairs(ESX.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = ESX.GetPlayerFromId(v)
        players[#players+1] = {
            name = ped.get('firstName') .. ' ' .. ped.get('lastName') .. ' | ' .. GetPlayerName(v),
            -- name = GetPlayerName(v),
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.get('firstName') .. ' ' .. ped.get('lastName'),
            -- citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.source),
            sourceplayer= ped.source
        }
    end
    TriggerClientEvent('qb-admin:client:Show', src, players)
end)

RegisterNetEvent('qb-admin:server:kill', function(player)
    TriggerClientEvent('pepe-hospital:client:KillPlayer', player.id)
end)

RegisterNetEvent('qb-admin:server:revive', function(player)
    TriggerClientEvent('pepe-hospital:client:revive', player.id)
end)

RegisterNetEvent('qb-admin:server:kick', function(player, reason)
    local src = source
    if IsPlayerAceAllowed(src, 'command')  then
        DropPlayer(player.id, 'Bạn đã bị kick khỏi server:\n' .. reason .. '\n\n🔸 Xem thông tin tại discord: https://discord.gg/DHntjapreK')
    end
end)

RegisterNetEvent('qb-admin:server:ban', function(player, time, reason)
    local src = source
    if IsPlayerAceAllowed(src, 'command') then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)

        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>THÔNG BÁO | Người chơi {0} đã bị ban với lý do:</strong> {1}</div>",
            args = {GetPlayerName(player.id), reason}
        })

        DropPlayer(player.id, 'Bạn đã bị ban với lý do:\n' .. reason .. '\n.\n🔸 Xem thông tin tại discord: https://discord.gg/DHntjapreK')
    end
end)

RegisterNetEvent('qb-admin:server:spectate')
AddEventHandler('qb-admin:server:spectate', function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('qb-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent('qb-admin:server:freeze')
AddEventHandler('qb-admin:server:freeze', function(player)
    local target = GetPlayerPed(player.id)
    if not frozen then
        frozen = true
        FreezeEntityPosition(target, true)
    else
        frozen = false
        FreezeEntityPosition(target, false)
    end
end)

RegisterNetEvent('qb-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('qb-admin:server:intovehicle', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    -- local coords = GetEntityCoords(GetPlayerPed(player.id))
    local targetPed = GetPlayerPed(player.id)
    local vehicle = GetVehiclePedIsIn(targetPed,false)
    local seat = -1
    if vehicle ~= 0 then
        for i=0,8,1 do
            if GetPedInVehicleSeat(vehicle,i) == 0 then
                seat = i
                break
            end
        end
        if seat ~= -1 then
            SetPedIntoVehicle(admin,vehicle,seat)
            TriggerClientEvent('ESX:Notify', src, 'Đã ngồi vào xe', 'success', 5000)
        else
            TriggerClientEvent('ESX:Notify', src, 'Xe đã hết chỗ!', 'danger', 5000)
        end
    else
        TriggerClientEvent('ESX:Notify', src, 'Người chơi không lái xe!', 'danger', 5000)
    end
end)


RegisterNetEvent('qb-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent('qb-admin:server:inventory', function(player)
    local src = source
    TriggerClientEvent('qb-admin:client:inventory', src, player.id)
end)

RegisterNetEvent('qb-admin:server:cloth', function(player)
    TriggerClientEvent('pepe-clothing:client:openMenu', player.id)
end)

RegisterNetEvent('qb-admin:server:setPermissions', function(targetId, group)
    local src = source
    -- if IsPlayerAceAllowed(src, 'command') then
    --     ESX.Functions.AddPermission(targetId, group[1].rank)
    --     TriggerClientEvent('ESX:Notify', targetId, 'Quyền hạn của bạn hiện tại là '..group[1].label)
    -- end
end)

RegisterNetEvent('qb-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {'Admin Report - '..name..' ('..targetSrc..')', msg}
        })
    end
end)

RegisterNetEvent('qb-admin:server:Staffchat:addMessage', function(name, msg)
    local src = source
    if IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('chat:addMessage', src, 'STAFFCHAT - '..name, 'error', msg)
    end
end)

RegisterNetEvent('qb-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    TriggerClientEvent('ESX:Notify', src, 'Đang phát triển!', 'success', 5000)

    -- local result = exports.oxmysql:executeSync('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    -- if result[1] == nil then
    --     exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
    --         Player.PlayerData.license,
    --         Player.PlayerData.citizenid,
    --         vehicle.model,
    --         vehicle.hash,
    --         json.encode(mods),
    --         plate,
    --         0
    --     })
    --     TriggerClientEvent('ESX:Notify', src, 'Đã lưu xe!', 'success', 5000)
    -- else
    --     TriggerClientEvent('ESX:Notify', src, 'Đã lưu xe..', 'error', 3000)
    -- end
end)

-- Commands

ESX.RegisterCommand('blips', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("qb-admin:client:toggleBlips")
end, true)

ESX.RegisterCommand('names', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("qb-admin:client:toggleNames")
end, true)

ESX.RegisterCommand('coords', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("qb-admin:client:ToggleCoords")
end, true)

ESX.RegisterCommand('noclip', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("qb-admin:client:ToggleNoClip")
end, true)

ESX.RegisterCommand('announce', "admin", function(xPlayer, args, showError)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Thông báo", msg}
    })
end, true)

ESX.RegisterCommand('admin', "admin", function(xPlayer, args, showError)
    xPlayer.triggerEvent("qb-admin:client:openMenu")
end, true)

ESX.RegisterCommand('staffchat', "admin", function(xPlayer, args, showError)
    local msg = table.concat(args, ' ')
    TriggerClientEvent('qb-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, true)

ESX.RegisterCommand('givenuifocus', "admin", function(xPlayer, args, showError)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('qb-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, true)

ESX.RegisterCommand('setmodel', "admin", function(xPlayer, args, showError)
    local src = xPlayer.source
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('qb-admin:client:SetModel', src, tostring(model))
        else
            local Trgt = ESX.GetPlayerFromId(target)
            if Trgt ~= nil then
                TriggerClientEvent('qb-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('ESX:Notify', src, 'Người chơi không online..', 'error')
            end
        end
    else
        TriggerClientEvent('ESX:Notify', source, 'Bạn cần nhập model name..', 'error')
    end
end, true)

ESX.RegisterCommand('setspeed', "admin", function(xPlayer, args, showError)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('qb-admin:client:SetSpeed', xPlayer.source, tostring(speed))
    else
        TriggerClientEvent('ESX:Notify', xPlayer.source, 'Vui lòng nhập tốc độ.. (`fast` = chạy nhanh, `normal` = chạy bình thường)', 'error')
    end
end, true)

ESX.RegisterCommand('fakecops', "admin", function(xPlayer, args, showError)
    if ESX.FakeCops() then
        TriggerClientEvent('ESX:Notify', xPlayer.source, 'Đã bật Fake Cops', 'error')
    else
        TriggerClientEvent('ESX:Notify', xPlayer.source, 'Đã tắt Fake Cops', 'error')
    end
end, true)