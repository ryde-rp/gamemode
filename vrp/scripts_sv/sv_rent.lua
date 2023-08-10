local rentPrice = 100

function tvRP.rentOneBike()
	local user_id = vRP.getUserId(source)
	return vRP.tryPayment(user_id, rentPrice, true)
end