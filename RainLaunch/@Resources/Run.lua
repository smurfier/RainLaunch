function Initialize()
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
	local args = Delim(command, '%s')
	
	if #args>0 then
		local func = string.lower(table.remove(args, 1))
		if string.match(command, '^=.+') then
			local value = SKIN:ParseFormula('('..string.match(command, '^=(.+)')..')')
			Output(value)
		elseif Search[func] and #args > 0 then -- Search
			local text = table.concat(args, '%%20')
			local line = string.gsub(Search[func], '\\1', text)
			SKIN:Bang('"'..line..'"')
		elseif func == 'web' and #args > 0 then -- Web
			local tbl = Delim(table.concat(args,'%%20'), '%.')
			SKIN:Bang('"http://'..(#tbl >= 3 and '' or 'www.')..table.concat(tbl,'.')..(#tbl >= 2 and '"' or '.com"'))
		elseif Execute[func] and #args > 0 then -- Custom
			if string.match(Execute[func],'\\%d') then
				local test = 0
				for num in string.gmatch(Execute[func], '\\(%d)') do if tonumber(num) > test then test=tonumber(num) end end
				if #args < test then
					Output(func..': Not Enough Parameters')
				else
					local err = false
					local text = string.gsub(Execute[func], '\\(%d)(%b{})', function(num, list)
						local par = tonumber(num) == test and table.concat(args, ' ', test) or (args[tonumber(num)] or '\\'..num)
						local sub
						if string.match(list, '{[^|}]+:') then
							sub, list = string.match(list, '{([^:]+):([^}]*)')
							sub = string.gsub(par, '%s', sub)
						end
						if string.len(list) > 0 then
							for word in string.gmatch(list, '[^%|{}]+') do
								local w,p = string.lower(word),string.lower(par)
								if w == p or string.match(p, w) then
									err = false
									return sub or par
								else
									err = true
								end
							end
						else
							return sub or par
						end
					end)
					text = string.gsub(text, '\\(%d)', function(num)
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
		elseif string.match(string.lower(command), '^http://') then -- Http
			SKIN:Bang('"'..command..'"')
		else -- Basic
			SKIN:Bang(Execute[string.lower(command)] or command)
		end
	end
	SKIN:Bang('!Update')
end

function Output(outtext)
	SKIN:Bang('!EnableMeasure', 'Reset')
	SKIN:Bang('!SetVariable', 'Output', outtext)
end

function Delim(input, delimiter)
	local tbl = {}
	for word in string.gmatch(input, '[^'..delimiter..']+') do table.insert(tbl, word) end
	return tbl
end