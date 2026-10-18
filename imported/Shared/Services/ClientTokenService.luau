local activeToken = {}

local ClientTokenService = {}

function ClientTokenService.Init(self: ClientTokenService)

end

function ClientTokenService.GetActiveToken(self: ClientTokenService, tag: string)
	if not tag or not activeToken[tag] then
		return
	end
	
	return activeToken[tag]
end

function ClientTokenService.SetActiveToken(self: ClientTokenService, tag: string, token: number)
	if not token then
		return
	end
	
	activeToken[tag] = token
end

type ClientTokenService = typeof(ClientTokenService) & {

}

return ClientTokenService