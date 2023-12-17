local EmergencyServicesBonus = {}

Cake.StartPayCheck = function()
	function payCheck()
		local xPlayers = Cake.GetPlayers()
		local societyPayments = {}

		for i=1, #xPlayers, 1 do
			local xPlayer = Cake.Characters.GetByPlayerId(xPlayers[i])
			local job     = xPlayer.job.name
			local salary  = math.floor(xPlayer.job.grade_salary * Config.PaycheckMultiplier)

			if salary > 0 then
				if job == 'unemployed' or not Config.Jobs[xPlayer.job.name] then -- unemployed/offduty
					xPlayer.addAccountMoney('bank', salary)
					TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, "Welfare Check", "You recieved $" .. salary .. ".", "#3dc91a", "fas fa-money-check-alt", 3000)
				elseif Config.Jobs[xPlayer.job.name].SocietyPay then 
					-- Mark to pay out of society
					if societyPayments[xPlayer.job.name] == nil then
						societyPayments[xPlayer.job.name] = {}
						societyPayments[xPlayer.job.name].payees = {}
						societyPayments[xPlayer.job.name].payees[xPlayer.source] = salary
						societyPayments[xPlayer.job.name].total = salary
					else
						societyPayments[xPlayer.job.name].payees[xPlayer.source] = salary
						societyPayments[xPlayer.job.name].total = societyPayments[xPlayer.job.name].total + salary
					end
				else -- generic job
					xPlayer.addAccountMoney('bank', salary)
					TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, xPlayer.job.label .. " Payroll", "You recieved $" .. salary .. ".", "#3dc91a", "fas fa-money-check-alt", 3000)
				end
			end
		end

		for k,v in pairs(societyPayments) do
			TriggerEvent('prp-core:Society:GetAccount', "society_" .. k, function(account)
				local canPay = false
				
				if account.money >= v.total then
					canPay = true
				end

				local employeeCount = 0
				for source, salary in pairs(v.payees) do
					local xPlayer = Cake.Characters.GetByPlayerId(source)

					if xPlayer ~= nil then
						if canPay then
							xPlayer.addAccountMoney('bank', salary)

							if Config.Jobs[xPlayer.job.name].Emergency then
								if EmergencyServicesBonus[xPlayer.identifier] ~= nil and EmergencyServicesBonus[xPlayer.identifier] == 1 then
										xPlayer.addAccountMoney('bank', 1000)

									TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, xPlayer.job.label .. " Payroll", "You recieved $" .. salary .. ", plus $1000.", "#3dc91a", "fas fa-money-check-alt", 10000)
	
									EmergencyServicesBonus[xPlayer.identifier] = nil
								else
									TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, xPlayer.job.label .. " Payroll", "You recieved $" .. salary .. ".", "#3dc91a", "fas fa-money-check-alt", 10000)
									EmergencyServicesBonus[xPlayer.identifier] = 1
								end
							else
								TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, xPlayer.job.label .. " Payroll", "You recieved $" .. salary .. ".", "#3dc91a", "fas fa-money-check-alt", 10000)
							end
						else
							TriggerClientEvent("prp-phone:Client:NewNotification", xPlayer.source, "Paycheck Missed", "The company is broke.", "#bd1c3a", "fas fa-money-check-alt", 10000)
						end
					end

					employeeCount = employeeCount + 1
				end

				if canPay then
					v.total = v.total - (employeeCount * 0)

					if v.total < 0 then
						v.total = 0
					end
	
					account.removeMoney(v.total)
					if account.name == "society_police" then
						local sudoCount = exports['prp-policedispatch']:GetPoliceOnline()
						exports['prp-tab']:WebhookBasic("DevSocietyWages", "Paychecks", '```diff\n--SOCIETY PAYCHECK--\n[Account]: ' .. account.name .. '\n[Employees]: ' .. tostring(employeeCount) .. ' (' .. tostring(sudoCount) .. ')\n[Amount Paid Out]: $'..v.total..'\n[Current Balance]: $'..account.money - v.total .. '```')
					else
						exports['prp-tab']:WebhookBasic("DevSocietyWages", "Paychecks", '```diff\n--SOCIETY PAYCHECK--\n[Account]: ' .. account.name .. '\n[Employees]: ' .. tostring(employeeCount) .. '\n[Amount Paid Out]: $'..v.total..'\n[Current Balance]: $'..account.money - v.total .. '```')
					end
				end
			end)
		end

		societyPayments = {}
		SetTimeout(Config.PaycheckInterval, payCheck)
	end

	SetTimeout(Config.PaycheckInterval, payCheck)
end
