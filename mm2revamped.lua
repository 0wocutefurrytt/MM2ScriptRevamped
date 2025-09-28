local module = {}
module["gameId"] = 0 -- 66654135 -- Restrict module to a certain game ID only. 0 allows all games.

local playerESP = false
local sheriffAimbot = false
local coinAutoCollect = false
local autoShooting = false
local shootOffset = 3.5

local phs = game:GetService("PathfindingService")

local fu = require(_G.YARHM.FUNCTIONS)

local function findMurderer()
	for _, i in ipairs(game.Players:GetPlayers()) do
		if i.Backpack:FindFirstChild("Knife") then
			return i
		end
	end
	for _, i in ipairs(game.Players:GetPlayers()) do
		if i.Character:FindFirstChild("Knife") then
			return i
		end
	end
	return nil
end

local function findSheriff()
	for _, i in ipairs(game.Players:GetPlayers()) do
		if i.Backpack:FindFirstChild("Gun") then
			return i
		end
	end
	for _, i in ipairs(game.Players:GetPlayers()) do
		if i.Character:FindFirstChild("Gun") then
			return i
		end
	end
	return nil
end

module["Name"] = "MM2 (Rescript)"

workspace.ChildAdded:Connect(function(ch)
	if ch.Name == "Normal" and playerESP then
		fu.notification("Map has loaded, waiting for roles...")
		repeat task.wait(1) until findMurderer()
		local listplayers = game.Players:GetChildren()
		for _, player in ipairs(listplayers) do
			if player.Character ~= nil then
				local character = player.Character
				if not character:FindFirstChild("PlayerESP") then
					local a = Instance.new("Highlight", script.Parent)
					a.Name = "PlayerESP"
					a.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					a.Adornee = character
					a.FillColor = Color3.fromRGB(255, 255, 255)
					task.spawn(function()
						if player == findMurderer() then
							a.FillColor = Color3.fromRGB(255,0,0)
						elseif player == findSheriff() then
							a.FillColor = Color3.fromRGB(0, 150, 255)
						else
							a.FillColor = Color3.fromRGB(0,255,0)
						end
						if a then
							if not player then return end
							a.Adornee = player.Character or player.CharactedAdded:Wait()
						end
					end)
				end
			end
		end
		fu.notification("Player ESP reloaded.")
	end
end)

workspace.ChildRemoved:Connect(function(ch)
	if ch.Name == "Normal" and playerESP then
		fu.notification("Game ended, removing Player ESPs.")
		for _, v in ipairs(script.Parent:GetChildren()) do if v.Name == "PlayerESP" then v:Destroy() end end
	end
end)

workspace.ChildAdded:Connect(function(ch)
	if script.Parent:FindFirstChild("GunESP") and ch.Name == "GunDrop" then
		script.Parent:FindFirstChild("GunESP").Adornee = ch
		script.Parent:FindFirstChild("GunESP").Enabled = true
		local bguiclone = script.Parent.DroppedGunBGUI:Clone()
		bguiclone.Parent = script.Parent
		bguiclone.Adornee = workspace:FindFirstChild("GunDrop")
		bguiclone.Enabled = true
		bguiclone.Name = "DGBGUIClone"
		fu.notification("Gun has been dropped! Find a yellow highlight.")
	end
end)

workspace.ChildRemoved:Connect(function(ch)
	if script.Parent:FindFirstChild("GunESP") and ch.Name == "GunDrop" then
		script.Parent:FindFirstChild("GunESP").Enabled = false
		if script.Parent:FindFirstChild("DBGUIClone") then
			script.Parent:FindFirstChild("DBGUIClone"):Destroy()
		end
		fu.notification("Someone has took the dropped gun.")
	end
end)

task.spawn(function()
	while task.wait(0.1) do
		if not coinAutoCollect then continue end
		if workspace:FindFirstChild("Normal") then
			if workspace:FindFirstChild("Normal"):FindFirstChild("CoinContainer") then
				local coin = workspace.Normal.CoinContainer:FindFirstChild("Coin_Server")
				if not coin then continue end
				local coinPosition = coin.Position
				local characterRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
				local rayDirection = coinPosition * 3
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
				local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
				if not hit or hit.Instance == coin then
					game.Players.LocalPlayer.Character:MoveTo(Vector3.new(coin:GetPivot().X, coin:GetPivot().Y, coin:GetPivot().Z))
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if findSheriff() == game.Players.LocalPlayer and autoShooting then
			fu.notification("Auto-shooting started.")
			repeat
				task.wait(0.1)
				local murderer = findMurderer()
				if not murderer then fu.notification("No murderer.") continue end
				local murdererPosition = murderer.Character.HumanoidRootPart.Position
				local characterRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
				local rayDirection = murdererPosition - characterRootPart.Position
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
				local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
				if not hit or hit.Instance.Parent == murderer.Character then
					fu.notification("Auto-shooting!")
					if not game.Players.LocalPlayer.Character:FindFirstChild("Gun") then
						if game.Players.LocalPlayer.Backpack:FindFirstChild("Gun") then
							game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Gun"))
						else
							fu.notification("You don't have the gun..?")
							return
						end
					end
					local args = {
						[1] = 1,
						[2] = findMurderer().Character:FindFirstChild("HumanoidRootPart").Position + findMurderer().Character:FindFirstChild("Humanoid").MoveDirection * shootOffset,
						[3] = "AH"
					}
					game:GetService("Players").LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
				end
			until findSheriff() ~= game.Players.LocalPlayer or not autoShooting
		end
	end
end)

module[1] = {Type="Text",Args={"ESPs"}}
module[2] = {
	Type = "ButtonGrid",
	Toggleable = true,
	Args = {2, {
		Players = function()
			if script.Parent:FindFirstChild("PlayerESP") then
				playerESP = false
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="PlayerESP" then i:Destroy() end end
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="DGBGUIClone" then i:Destroy() end end
			else
				playerESP = true
				local listplayers = game.Players:GetChildren()
				for _, player in ipairs(listplayers) do
					if player.Character ~= nil then
						local character = player.Character
						if not character:FindFirstChild("PlayerESP") then
							local a = Instance.new("Highlight", script.Parent)
							a.Name = "PlayerESP"
							a.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							a.Adornee = character
							a.FillColor = Color3.fromRGB(255, 255, 255)
							task.spawn(function()
								if player == findMurderer() then
									a.FillColor = Color3.fromRGB(255,0,0)
								elseif player == findSheriff() then
									a.FillColor = Color3.fromRGB(0, 150, 255)
								else
									a.FillColor = Color3.fromRGB(0,255,0)
								end
								if a then
									if not player then return end
									a.Adornee = player.Character or player.CharactedAdded:Wait()
								end
							end)
						end
					end
				end
			end
		end,
		Dropped_Gun = function()
			if script.Parent:FindFirstChild("GunESP") then
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="GunESP" then i:Destroy() end end
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="DGBGUIClone" then i:Destroy() end end
			else
				local gunesp = Instance.new("Highlight", script.Parent)
				gunesp.OutlineTransparency = 1
				gunesp.FillColor = Color3.fromRGB(255, 255, 0)
				gunesp.Name = "GunESP"
				gunesp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				gunesp.Enabled = false
				if workspace:FindFirstChild("GunDrop") then
					gunesp.Adornee = workspace:FindFirstChild("GunDrop")
					gunesp.Enabled = true
					local bguiclone = script.Parent.DroppedGunBGUI:Clone()
					bguiclone.Parent = script.Parent
					bguiclone.Adornee = workspace:FindFirstChild("GunDrop")
					bguiclone.Enabled = true
					bguiclone.Name = "DGBGUIClone"
					fu.notification("Gun has been dropped! Find a yellow highlight.")
				end
			end
		end,
	}}
}
module[3] = {Type="Text",Args={"Tools"}}
module[4] = {
	Type = "Button",
	Args = {"Shoot murderer", function(Self)
		if findSheriff() ~= game.Players.LocalPlayer then fu.notification("You're not sheriff/hero.") return end
		if not findMurderer() then fu.notification("No murderer to shoot.") return end
		if not game.Players.LocalPlayer.Character:FindFirstChild("Gun") then
			if game.Players.LocalPlayer.Backpack:FindFirstChild("Gun") then
				game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Gun"))
			else
				fu.notification("You don't have the gun..?")
				return
			end
		end
		local args = {
			[1] = 1,
			[2] = findMurderer().Character:FindFirstChild("HumanoidRootPart").Position + findMurderer().Character:FindFirstChild("Humanoid").MoveDirection * shootOffset,
			[3] = "AH"
		}
		game:GetService("Players").LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
	end,}
}
module[5] = {
	Type = "Input",
	Args = {"Shoot position offset", "Set", function(Self, text)
		if not tonumber(text) then fu.notification("Not a valid number.") return end
		if tonumber(text) > 10 then fu.notification("An offset with a multiplier of 10 might not at all shoot the murderer!") end
		if tonumber(text) < 0 then fu.notification("An offset with a negative multiplier will make a shot BEHIND the murderer's walk direction.") end
		shootOffset = tonumber(text)
		fu.notification("Offset has been set.")
	end,}
}
module[6] = {Type="Text",Args={"The automatic murderer's shots can miss when the murderer moves. Shoot offset adjusts for the murderer's movement. Recommended is 3."}}
module[7] = {
	Type = "ButtonGrid",
	Toggleable = true,
	Args = {1, {
		Coins_Magnet = function()
			coinAutoCollect = not coinAutoCollect
			if coinAutoCollect then fu.notification("Coins magnet is currently buggy right now. Use at your own risk.") end
		end,
		Auto_Shoot_murderer = function()
			autoShooting = not autoShooting
			if findSheriff() == game.Players.LocalPlayer and autoShooting then
				fu.notification("Auto-shooting started.")
				repeat
					task.wait(0.1)
					local murderer = findMurderer()
					if not murderer then fu.notification("No murderer.") continue end
					local murdererPosition = murderer.Character.HumanoidRootPart.Position
					local characterRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
					local rayDirection = murdererPosition - characterRootPart.Position
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
					local hit = workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
					if not hit or hit.Instance.Parent == murderer.Character then
						fu.notification("Auto-shooting!")
						if not game.Players.LocalPlayer.Character:FindFirstChild("Gun") then
							if game.Players.LocalPlayer.Backpack:FindFirstChild("Gun") then
								game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Gun"))
							else
								fu.notification("You don't have the gun..?")
								return
							end
						end
						local args = {
							[1] = 1,
							[2] = findMurderer().Character:FindFirstChild("HumanoidRootPart").Position + findMurderer().Character:FindFirstChild("Humanoid").MoveDirection * shootOffset,
							[3] = "AH"
						}
						game:GetService("Players").LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
					end
				until findSheriff() ~= game.Players.LocalPlayer or not autoShooting
			end
		end,
	}}
}
module[8] = {Type="Text",Args={""}}
module[9] = {Type="Text",Args={"The tools below can be <font color='#FF0000'>detected,</font> both game-wise and player-wise. Use at your own risk.","center"}}
module[10] = {
	Type = "Button",
	Args = {"Fast-move to dropped gun", function(Self)
		if not workspace:FindFirstChild("GunDrop") then fu.notification("No dropped gun to be teleported to.") return end
		fu.notification("Teleporting to dropped gun...")
		local gunPos = workspace:FindFirstChild("GunDrop"):GetPivot().Position
		local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	end,}
}

module[11] = {
	Type = "Button",
	Args = {"Fling everyone but murderer/sheriff", function()
		local lp = game.Players.LocalPlayer
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for _,plr in ipairs(game.Players:GetPlayers()) do
			if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				if plr ~= findMurderer() and plr ~= findSheriff() then
					local target = plr.Character.HumanoidRootPart
					task.spawn(function()
						for i=1,30 do
							target.Velocity = Vector3.new(0,200,0)
							task.wait(0.05)
						end
					end)
				end
			end
		end
	end}
}

_G.Modules[11] = module
