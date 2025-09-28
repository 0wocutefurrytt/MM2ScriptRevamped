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

_G.Modules[4] = module
