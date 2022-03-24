local id = DanLib.Config.Style.ID
local Materials = DanLib.Config.Materials

--hook.Add('DanLib::ModulesLoaded', 'DanLib::ThemeParser', function()
	for k, v in pairs(Materials) do
	    local path = 'DanLib/popups/'..id..'/'..string.lower(k)..'.png'
		local dPath = 'data/'..path

		if(file.Exists(path, 'DATA')) then Materials[k] = Material(dPath, 'mips') end
		if(not file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end


		http.Fetch(v, function(body, size, headers, code)
			if(code != 200) then return errorCallback(code) end
			file.Write(path, body)
			Materials[k] = Material(dPath, 'mips')
	        
		end)
	end
	hook.Call('DanLib::IconLoaded')
--end)


--[[local Id = CMRP.Config.Description.ID
local Materialss = CMRP.Config.Materials

--hook.Add('DanLib::ModulesLoaded', 'DanLib::ThemeParser', function()
	for k, v in pairs(Materialss) do
	    local path = 'cmrp/basic/'..Id..'/'..string.lower(k)..'.png'
		local dPath = 'data/'..path

		if(file.Exists(path, 'DATA')) then Materialss[k] = Material(dPath, 'mips') end
		if(not file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end


		http.Fetch(v, function(body, size, headers, code)
			if(code != 200) then return errorCallback(code) end
			file.Write(path, body)
			Materialss[k] = Material(dPath, 'mips')
	        
		end)
	end
	hook.Call('DanLib::IconLoaded')
--end)]]