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

module["Name"] = "Murder Mystery 2 (revamped)"

-- Player ESP
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
							a.FillColor = Color3.fromRGB(0,150,255)
						else
							a.FillColor = Color3.fromRGB(0,255,0)
						end
						if a and player then
							a.Adornee = player.Character or player.CharacterAdded:Wait()
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
		for _, v in ipairs(script.Parent:GetChildren()) do 
			if v.Name == "PlayerESP" then v:Destroy() end 
		end
	end
end)

-- Dropped Gun ESP
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

-- Coin autocollect
task.spawn(function()
	while task.wait(0.1) do
		if not coinAutoCollect then continue end
		if workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer") then
			local coin = workspace.Normal.CoinContainer:FindFirstChild("Coin_Server")
			if not coin then continue end
			local characterRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
			game.Players.LocalPlayer.Character:MoveTo(coin.Position)
		end
	end
end)

-- Auto-shooting
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
						[2] = murderer.Character.HumanoidRootPart.Position + murderer.Character.Humanoid.MoveDirection * shootOffset,
						[3] = "AH"
					}
					game:GetService("Players").LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
				end
			until findSheriff() ~= game.Players.LocalPlayer or not autoShooting
		end
	end
end)

-- UI Buttons
module[1] = {Type="Text", Args={"ESPs"}}
module[2] = {
	Type="ButtonGrid", Toggleable=true,
	Args={2,{
		Players=function()
			playerESP = not playerESP
			if not playerESP then
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="PlayerESP" then i:Destroy() end end
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="DGBGUIClone" then i:Destroy() end end
			else
				local listplayers = game.Players:GetChildren()
				for _, player in ipairs(listplayers) do
					if player.Character ~= nil and not player.Character:FindFirstChild("PlayerESP") then
						local a = Instance.new("Highlight", script.Parent)
						a.Name = "PlayerESP"
						a.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						a.Adornee = player.Character
						a.FillColor = Color3.fromRGB(255,255,255)
						task.spawn(function()
							if player == findMurderer() then
								a.FillColor = Color3.fromRGB(255,0,0)
							elseif player == findSheriff() then
								a.FillColor = Color3.fromRGB(0,150,255)
							else
								a.FillColor = Color3.fromRGB(0,255,0)
							end
							if a and player then
								a.Adornee = player.Character or player.CharacterAdded:Wait()
							end
						end)
					end
				end
			end
		end,
		Dropped_Gun=function()
			if script.Parent:FindFirstChild("GunESP") then
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="GunESP" then i:Destroy() end end
				for _, i in ipairs(script.Parent:GetChildren()) do if i.Name=="DGBGUIClone" then i:Destroy() end end
			else
				local gunesp = Instance.new("Highlight", script.Parent)
				gunesp.OutlineTransparency = 1
				gunesp.FillColor = Color3.fromRGB(255,255,0)
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

module[3] = {Type="Text", Args={"Tools"}}
module[4] = {
	Type="Button",
	Args={"Shoot murderer",function(Self)
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
			[2] = findMurderer().Character.HumanoidRootPart.Position + findMurderer().Character.Humanoid.MoveDirection * shootOffset,
			[3] = "AH"
		}
		game:GetService("Players").LocalPlayer.Character.Gun.KnifeServer.ShootGun:InvokeServer(unpack(args))
	end}
}
module[5] = {
	Type="Input",
	Args={"Shoot position offset","Set",function(Self,text)
		if not tonumber(text) then fu.notification("Not a valid number.") return end
		shootOffset = tonumber(text)
		fu.notification("Offset has been set.")
	end}
}
module[6] = {Type="Text", Args={"The automatic murderer's shots can miss when the murderer moves. Shoot offset adjusts for the murderer's movement. Recommended is 3."}}
module[7] = {
	Type="ButtonGrid", Toggleable=true,
	Args={1,{
		Coins_Magnet=function()
			coinAutoCollect = not coinAutoCollect
			if coinAutoCollect then
				fu.notification("Coins magnet is currently buggy right now. Use at your own risk.")
			end
		end,
		Auto_Shoot_murderer=function()
			autoShooting = not autoShooting
		end,
	}}
}
module[8] = {Type="Text", Args={""}}
module[9] = {Type="Text", Args={"The tools below can be <font color='#FF0000'>detected,</font> both game-wise and player-wise. Use at your own risk.","center"}}

-- Fast move to dropped gun (no snap back)
module[10] = {
	Type="Button",
	Args={"Fast-move to dropped gun",function(Self)
		if not workspace:FindFirstChild("GunDrop") then 
			fu.notification("No dropped gun to be teleported to.") 
			return 
		end
		fu.notification("Teleporting to dropped gun...")
		local gunPos = workspace:FindFirstChild("GunDrop"):GetPivot().Position
		local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(gunPos + Vector3.new(0,3,0))
	end}
}

-- Fling everyone except murderer and sheriff
module[11] = {
	Type="Button",
	Args={"Fling others (not murderer/sheriff)", function(Self)
		local plr = game.Players.LocalPlayer
		if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end

		local murderer = findMurderer()
		local sheriff = findSheriff()

		local function flingPlayer(p)
			local char = p.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local ok, _ = pcall(function()
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5,1e5,1e5)
				local dir = (hrp.Position - plr.Character.HumanoidRootPart.Position)
				if dir.Magnitude == 0 then
					dir = Vector3.new(math.random(-1,1),1,math.random(-1,1))
				end
				bv.Velocity = dir.Unit * 200 + Vector3.new(0,50,0)
				bv.Parent = hrp
				task.delay(0.45, function()
					if bv and bv.Parent then pcall(function() bv:Destroy() end) end
				end)
			end)
			return ok
		end

		for _, p in ipairs(game.Players:GetPlayers()) do
			if p ~= plr and p ~= murderer and p ~= sheriff then
				pcall(function() flingPlayer(p) end)
			end
		end
	end}
}

_G.Modules[#_G.Modules + 1] = module
