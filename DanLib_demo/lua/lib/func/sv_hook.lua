hook.Add("PlayerInitialSpawn", "DanLibСheckInt", function(pPlayer)
	net.Start("DanLibСheckInt")
	net.Send(pPlayer)
end)