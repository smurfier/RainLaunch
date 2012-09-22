function Initialize()
	File = ReadIni(SKIN:GetVariable('@') .. 'Run.cfg')
end

function ReadIni(inputfile)
	local file = io.open(inputfile, 'r')
	local tbl, include, section = {}, {}
	if not file then
		print('Unable to open ' .. inputfile)
	else
		local num = 0
		for line in file:lines() do
			num = num + 1
			if not line:match('^%s-;') then
				local key, command = line:match('^([^=]+)=(.+)')
				if line:match('^%s-%[.+') then
					section = line:lower():match('^%s-%[([^%]]+)')
					if not tbl[section] then tbl[section] = {} end
				elseif key and command and section then
					local nkey, ncommand = key:lower():match('^%s*(%S*)%s*$'), command:match('^%s*(.-)%s*$')
					if nkey:match('@include') then
						table.insert(include, ReadIni(SKIN:MakePathAbsolute(SKIN:ReplaceVariables(ncommand))))
					else
						tbl[section][nkey] = ncommand
					end
				elseif #line > 0 and section and not key or command then
					print(num..': Invalid property or value.')
				end
			end
		end
		if not section then print('No sections found in '..inputfile) end
		if #include > 0 then
			for _, a in pairs(include) do
				for s, list in pairs(a) do
					for k, c in pairs(list) do
						if not tbl[s][k] then
							tbl[s][k] = c
						end
					end
				end
			end
		end
		file:close()
	end
	return tbl
end

function Run()
	local command = SKIN:GetVariable('Run')
	local func = string.lower(command:match('^%s-(%S+)') or '')
	
	if func:len() > 0 then
		local args = Params(command:match('^%s-%a+ (.+)') or '')
		if command:match('^=.+') then
			local value = SKIN:ParseFormula('('..command:match('^=(.+)')..')')
			Output(value)
		elseif File.search[func] and #args > 0 then -- Search
			local text = table.concat(args, '%%20')
			local line = File.search[func]:gsub('\\1', text)
			SKIN:Bang('"'..line..'"')
		elseif func == 'web' and #args > 0 then -- Web
			local tbl = {}
			for word in table.concat(args,'%%20'):gmatch('[^.]+') do table.insert(tbl, word) end
			SKIN:Bang('"http://'..(#tbl >= 3 and '' or 'www.')..table.concat(tbl,'.')..(#tbl >= 2 and '"' or '.com"'))
		elseif File.macros[func] and #args > 0 and string.match(File.macros[func] or '','\\%d') then -- Custom
			local test = 0
			for num in File.macros[func]:gmatch('\\(%d)') do if tonumber(num) > test then test = tonumber(num) end end
			if #args < test then
				Output(func..': Not Enough Parameters')
			else
				local err = false
				local text = File.macros[func]:gsub('\\(%d)(%b{})', function(num, list)
					local par = tonumber(num) == test and table.concat(args, ' ', test) or (args[tonumber(num)] or '\\'..num)
					local sub
					if list:match('{[^|}]+:') then
						sub, list = list:match('{([^:]+):([^}]*)')
						sub = par:gsub('%s', sub)
					end
					if list:len() > 0 then
						for word in list:gmatch('[^|{}]+') do
							local w, p = word:lower(), par:lower()
							if w == p or p:match(w) then
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
				text = text:gsub('\\(%d)', function(num)
					return tonumber(num) == test and table.concat(args, ' ', test) or (args[tonumber(num)] or '\\'..num)
				end)
				if not err then
					Send(text)
				else
					Output(func..': Invalid Parameter')
				end
			end
		elseif command:lower():match('^http://') then -- Http
			Send('"'..command..'"')
		else -- Basic
			Send(File.macros[command:lower()] or command)
		end
	end
	SKIN:Bang('!Update')
end

function Send(com)
	local lbang = com:match('^%s-!(%a+)')
	local parms = com:match('^%s-!%a+ (.+)')
	
	local tbl = {
		writetofile = function()
			--!WriteToFile File Text Match
			local tbl = Params(parms)
			if #tbl >= 2 then
				local hFile = io.open(SKIN:MakePathAbsolute(tbl[1]), 'r')
				if hFile then
					local text = hFile:read('*all')
					hFile:close()
					local rfile = function(...)
						hFile = io.open(SKIN:MakePathAbsolute(tbl[1]), 'w')
						hFile:write(unpack(arg))
						hFile:close()
					end
					if #tbl == 3 then
						local start = text:lower():find(tbl[3]:lower())
						if start then
							rfile(text:sub(1, start-1), tbl[2], text:sub(start))
						else
							rfile(text, text:len()>0 and '\n' or '', tbl[2])
						end
					else
						rfile(text, text:len()>0 and '\n' or '', tbl[2])
					end
				else
					Output('Invalid File: '..tbl[1])
				end
			end
		end,
		
		default = function()
			SKIN:Bang(com)
		end
	}
	
	local f = tbl[string.lower(lbang or '')] or tbl.default
	f()
end

function Params(line)
	local tbl,temp = {},{}
	local quote
	local add = function(input) table.insert(tbl, SKIN:ReplaceVariables(input)) end
	for word in line:gmatch('%S+') do
		if word:match('^"') and not quote then -- Start Quote.
			quote = word:match('^"""') and '"""' or '"'
			if word:match(quote..'$') then -- Make allowance for parameters using quotes without spaces.
				add(word:match(quote..'(.+)'..quote))
				quote = nil
			else
				table.insert(temp, word)
			end
		elseif word:match((quote or '')..'$') and #temp > 0 then -- Finish quote.
			table.insert(temp, word)
			local nword = table.concat(temp, ' '):match(quote..'(.+)'..quote)
			add(nword)
			temp,quote = {}
		elseif quote then -- Between Quotes.
			table.insert(temp, word)
		else
			add(word)
		end
	end
	return tbl
end

function Output(outtext)
	SKIN:Bang('!EnableMeasure', 'Reset')
	SKIN:Bang('!SetVariable', 'Output', outtext)
end