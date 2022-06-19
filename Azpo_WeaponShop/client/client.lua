ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(ConfAmmu.Pos) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)

		SetBlipSprite(blip, 110)
		SetBlipScale (blip, 0.75)
		SetBlipColour(blip, 3)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Armurerie')
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
    local hash = GetHashKey("s_m_m_ammucountry")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(50)
	end
	for k,v in pairs(ConfAmmu.AmmuPed) do
	ped = CreatePed("PED_TYPE_CIVMALE", "s_m_m_ammucountry", v.x, v.y, v.z, v.a, false, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
	end
end)

ppa = false

Citizen.CreateThread(function()
	while true do
		local wait = 750
		local playerCoords = GetEntityCoords(PlayerPedId())

		for k, v in pairs(ConfAmmu.Pos) do
			local distance = GetDistanceBetweenCoords(playerCoords, v.x, v.y, v.z, true)

            if distance < 10.0 then

                wait = 0

                actualZone = v

                zoneDistance = GetDistanceBetweenCoords(playerCoords, actualZone.x, actualZone.y, actualZone.z, true)

				DrawMarker(21, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.4, 10, 10, 255, 100, false, true, 2, false, nil, nil, false)
            end
            
            if distance <= 1.5 then
                wait = 0
				RageUI.Text({
					message = "Appuyez sur [~b~E~w~] pour ouvrir l'armurerie",
					time_display = 1
				})

                if IsControlJustPressed(1, 51) then
                    tcheckboucle()
                    open_ammu()
                end
            end

            if zoneDistance ~= nil then
                if zoneDistance > 1.5 then
                    RageUI.CloseAll()
                end
            end
        end
    	Citizen.Wait(wait)
	end
end)

RMenu.Add('azpo_ammu', 'main', RageUI.CreateMenu("Ammunation", "Armurerie"))
RMenu.Add('azpo_ammu', 'armurerie', RageUI.CreateSubMenu(RMenu:Get('azpo_ammu', 'main'), "Armurerie", "Voici nos armes blanche."))
RMenu.Add('azpo_ammu', 'arme', RageUI.CreateSubMenu(RMenu:Get('azpo_ammu', 'main'), "Armurerie", "Voici nos armes à feu."))
RMenu.Add('azpo_ammu', 'aces', RageUI.CreateSubMenu(RMenu:Get('azpo_ammu', 'main'), "Armurerie", "Voici nos accessoires."))
RMenu.Add('azpo_ammu', 'ppa', RageUI.CreateSubMenu(RMenu:Get('azpo_ammu', 'main'), "Armurerie", "Confirmation"))
RMenu:Get("azpo_ammu", "main").Closed = function()
    ammumenu = false
end

function tcheckboucle()
    ESX.TriggerServerCallback('a_weaponshop:checkLicense', function(cb)            
        if cb then
            ppa = true 
            else 
             ppa = false   
        end
    end)
end

function open_ammu()
    if ammumenu then
        ammumenu = false
        RageUI.CloseAll()
    else
        ammumenu = true
        RageUI.Visible(RMenu:Get("azpo_ammu","main"), true)
        Citizen.CreateThread(function()
            while ammumenu do
                Citizen.Wait(1)
        RageUI.IsVisible(RMenu:Get('azpo_ammu', 'main'), true, true, true, function()

            RageUI.ButtonWithStyle("Armes blanche", "Pour accéder aux armes blanche.", {RightLabel = "→"},true, function()
            end, RMenu:Get('azpo_ammu', 'armurerie'))

            if ppa then 
            RageUI.ButtonWithStyle("Armes à feu", "Pour accéder aux armes à feu.", { RightLabel = "→" }, true, function(Hovered, Active, Selected)     
            end, RMenu:Get('azpo_ammu', 'arme')) 
            else 
            RageUI.ButtonWithStyle("Armes à feu", "Pour accéder aux armes à feu.", { RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)     
            end) 
            end


			RageUI.ButtonWithStyle("Accessoires", "Pour accéder aux accessoires.", {RightLabel = "→"},true, function()
            end, RMenu:Get('azpo_ammu', 'aces')) 

            if ppa then
            RageUI.ButtonWithStyle("Acheter le P.P.A", "Vous avez le PPA.", { RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)     
            end)
            else 
			RageUI.ButtonWithStyle("Acheter le P.P.A", "Permet de débloquer les armes à feu", {RightLabel = "~g~50,000$"},true, function()
            end, RMenu:Get('azpo_ammu', 'ppa'))
            end


        end, function()
        end)

		RageUI.IsVisible(RMenu:Get('azpo_ammu', 'ppa'), true, true, true, function()

                RageUI.ButtonWithStyle("Confirmer", nil, { }, true, function(Hovered, Active, Selected)
                    if Selected then
						local prix = 50000
						TriggerServerEvent('Aweapon:addppa', 'weapon')
						RageUI.GoBack()
                    end
                end)

				RageUI.ButtonWithStyle("~r~Annuler", nil, { }, true, function(Hovered, Active, Selected)
                    if Selected then
						RageUI.GoBack()
                    end
                end)

        end, function()
        end)

        RageUI.IsVisible(RMenu:Get('azpo_ammu', 'armurerie'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Blanche) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('weaponshops:giveWeapon', v)
                    end
                end)
            end

        end, function()
        end)

		RageUI.IsVisible(RMenu:Get('azpo_ammu', 'arme'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Armes) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('weaponshops:giveWeapon', v)
                    end
                end)
            end

        end, function()
        end)

        RageUI.IsVisible(RMenu:Get('azpo_ammu', 'aces'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Items) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('item:acheter', v)
                    end
                end)
            end
			
        end, function()
        end, 1)
    end
end)
	Citizen.Wait(100)
    end
end

RegisterNetEvent('azpo:kevlar')
AddEventHandler('azpo:kevlar', function()

    local playerPed = PlayerPedId()

    AddArmourToPed(playerPed,100)
    SetPedArmour(playerPed, 100)

end)


