local module = {}

module["Name"] = "Custom (WIP)"

module[1] = {
	Type = "Text",
	Args = {"Hello!"}
}

module[2] = {
	Type = "Button",
	Args = {"Say hi", function(Self)
		print("Hi!")
	end,}
}

module[3] = {
	Type = "Button",
	Args = {"Print players in console", function(Self)
		for _, p in ipairs(game.Players:GetPlayers()) do
			print(p.Name)
		end
	end,}
}

local selectedPlayer = nil

module[4] = {
	Type = "Dropdown",
	Args = {"Select Player", function(Self, value)
		selectedPlayer = game.Players:FindFirstChild(value)
	end, function()
		local names = {}
		for _, p in ipairs(game.Players:GetPlayers()) do
			table.insert(names, p.Name)
		end
		return names
	end,}
}

module[5] = {
	Type = "Button",
	Args = {"Teleport To", function(Self)
		if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end,}
}

module[6] = {
	Type = "Button",
	Args = {"Fling", function(Self)
		if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(9999, 9999, 9999)
				bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bv.Parent = selectedPlayer.Character.HumanoidRootPart
				game:GetService("Debris"):AddItem(bv, 0.1)
			end
		end
	end,}
}

_G.Modules[4] = module
