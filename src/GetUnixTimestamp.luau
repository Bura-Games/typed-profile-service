--!native
--!optimize 2
--!strict

-- Possible functions:
-- os.time - The original version. Definitely works, but is not completely reliable.
-- DateTime.now().UnixTimestamp -- Really slow, but it does seem to work all the same.
-- math.floor(Workspace:GetServerTimeNow()) -- Will this work? Maybe?

local function GetUnixTimestamp()
	return os.time()
end

return GetUnixTimestamp
