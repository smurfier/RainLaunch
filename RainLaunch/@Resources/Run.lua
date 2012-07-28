function Initialize()
	local file = io.input(SKIN:GetVariable('@') .. 'Run.cfg')
	Execute = {}
	Search = {}
	local section
	if io.type(file) == 'file' then
		for line in io.lines() do
			if not string.match(line,'^;')then
				local key,command = string.match(line, '^([^=]+)=(.+)')
				if string.match(line, '^%s-%[.+') then
					section = string.lower(string.match(line, '^%s-%[([^%]]+)'))
				elseif key and command and section then
					local nkey = string.lower(key)
					if section == 'search' then
						Search[nkey]=command
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
	SKIN:Bang('!SetVariable','Output','Run...')
	local command = SKIN:GetVariable('Run')
	local func,term = string.match(command, '^([^%s]+) (.+)')
	func = string.lower(func or '')
	
	if Search[func] and term then
		local text = string.gsub(term, '%s', '%%%%20')
		local line = string.gsub(Search[func], '%$UserInput%$', term)
		SKIN:Bang('"'..line..'"')
	elseif func == 'web' and term then
		local tbl = {}
		for word in string.gmatch(term, '[^%.]+') do table.insert(tbl, word) end
		SKIN:Bang('"http://'..(#tbl>=3 and '' or 'www.')..table.concat(tbl,'.')..(#tbl>=2 and '"' or '.com"'))
	elseif func == 'calc' and term then
		local value = SKIN:ParseFormula('('..term..')')
		SKIN:Bang('!SetVariable', 'Output', value)
	elseif Execute[func] and term then
		if string.match(Execute[func],'\\%d') then
			local test = 0
			for num in string.gmatch(Execute[func], '\\(%d)') do if tonumber(num)>test then test=tonumber(num) end end
			local tbl = {}
			for word in string.gmatch(term, '[^%s]+') do table.insert(tbl,word) end
			if #tbl < test then
				SKIN:Bang('!SetVariable','OutPut',func..': Not Enough Parameters')
			else
				local text = string.gsub(Execute[func], '\\(%d)', function(a)
					return tonumber(a)==test and table.concat(tbl,' ',test) or (tbl[tonumber(a)] or '')
				end)
				SKIN:Bang(text)
			end
		else
			SKIN:Bang(Execute[string.lower(command)] or command)
		end
	elseif string.match(string.lower(command), '^http://') then
		SKIN:Bang('"'..command..'"')
	else
		SKIN:Bang(Execute[string.lower(command)] or command)
	end
	SKIN:Bang('!Update')
end