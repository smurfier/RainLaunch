function Initialize()
	Timer = -1
	local file = io.input(SKIN:GetVariable('@') .. 'Run.cfg')
	Execute = {}
	Search = {}
	local section
	if io.type(file) == 'file' then
		for line in io.lines() do
			if not string.match(line, '^;')then
				local key,command = string.match(line, '^([^=]+)=(.+)')
				if string.match(line, '^%s-%[.+') then
					section = string.lower(string.match(line, '^%s-%[([^%]]+)'))
				elseif key and command and section then
					local nkey = string.lower(key)
					if section == 'search' then
						Search[nkey] = command
					elseif section == 'macros' then
						Execute[nkey] = command
					end
				end
			end
		end
		io.close(file)
	end
end

function Run()
	local command = SKIN:GetVariable('Run')
	local args = {}
	for word in string.gmatch(command, '[^%s]+') do table.insert(args, word) end
	
	if #args>0 then
		local func = string.lower(table.remove(args, 1))
		if Search[func] and #args > 0 then
			local text = table.concat(args, '%%20')
			local line = string.gsub(Search[func], '\\1', text)
			SKIN:Bang('"'..line..'"')
		elseif func == 'web' and #args > 0 then
			local tbl = {}
			for word in string.gmatch(table.concat(args,'%%20'), '[^%.]+') do table.insert(tbl, word) end
			SKIN:Bang('"http://'..(#tbl >= 3 and '' or 'www.')..table.concat(tbl,'.')..(#tbl >= 2 and '"' or '.com"'))
		elseif func == 'calc' and #args > 0 then
			local value = SKIN:ParseFormula('('..table.concat(args)..')')
			Output(value)
		elseif Execute[func] and #args > 0 then
			if string.match(Execute[func],'\\%d') then
				local test = 0
				for num in string.gmatch(Execute[func], '\\(%d)') do if tonumber(num) > test then test=tonumber(num) end end
				if #args < test then
					Output(func..': Not Enough Parameters')
				else
					local err = false
					local text = string.gsub(Execute[func], '\\(%d)(%b{})', function(num, list)
						local par = tonumber(num) == test and table.concat(args, ' ', test) or (args[tonumber(num)] or '\\'..num)
						for word in string.gmatch(list, '[^%|{}]+') do
							local w,p = string.lower(word),string.lower(par)
							if w == p or string.match(p, w) then
								return par
							else
								err = true
							end
						end
					end)
					text = string.gsub(text, '\\(%d)', function(num, list)
						return tonumber(num) == test and table.concat(args, ' ', test) or (args[tonumber(num)] or '\\'..num)
					end)
					if not err then
						SKIN:Bang(text)
					else
						Output(func..': Invalid Parameter')
					end
				end
			else
				SKIN:Bang(Execute[string.lower(command)] or command)
			end
		elseif string.match(string.lower(command), '^http://') then
			SKIN:Bang('"'..command..'"')
		else
			SKIN:Bang(Execute[string.lower(command)] or command)
		end
	end
	SKIN:Bang('!Update')
end

function Output(outtext)
	SKIN:Bang('!EnableMeasure', 'Reset')
	SKIN:Bang('!SetVariable', 'Output', outtext)
end