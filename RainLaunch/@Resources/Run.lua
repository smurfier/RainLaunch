function Initialize()
	File = ReadIni(SKIN:GetVariable('@') .. 'Run.cfg')
	Timer, OutputText = 0, nil
	Output = function(outtext) OutputText, Timer = outtext, 300 end
end

function Update()
	if Timer > 0 then
		Timer = Timer - 1
	elseif Timer == 0 then
		OutputText = nil
	end

	return OutputText or 'Run...'
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
				if line:match('^%s-%[.+%]') then
					section = line:lower():match('^%s-%[([^%]]+)')
					if not tbl[section] then tbl[section] = {} end
				elseif key and command and section then
					tbl[section][key:lower():match('^%s*(%S*)%s*$')] = command:match('^%s*(.-)%s*$')
				elseif #line > 0 and section and not key or command then
					print(num..': Invalid property or value.')
				end
			end
		end
		if not section then print('No sections found in ' .. inputfile) end
		file:close()
	end
	return tbl
end

function Run(command)
	OutputText, Timer = nil, 0
	local func = (command:match('^%s-(%S+)') or ''):lower()
	
	if func:len() > 0 then
		local args = Params(command:match('^%s-%a+ (.+)') or '')

		if command:match('^=.+') then
			local value = SKIN:ParseFormula(('(%s)'):format(command:match('^=(.+)')))
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
			SKIN:Bang('"'..command..'"')

		else -- Basic
			Send(File.macros[command:lower()] or command)
		end
	end
	SKIN:Bang('!Update')
end

function Send(com)
	com = SKIN:ReplaceVariables(com) -- Make allowance for Section Variables

	local parse = function(input)
		local lbang = (input:match('^%s-!(%a+)') or ''):lower()

		if lbang == 'writetofile' then
			--!WriteToFile [File] [Text] (Match)
			local tbl = Params(input:match('^%s-!%a+ (.+)'))
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
							rfile(text:sub(1, start - 1), tbl[2], text:sub(start))
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
		else
			SKIN:Bang(input)
		end
	end

	if com:match('^%[') then
		for bang in com:gmatch('%[([^%]]+)%]') do parse(bang) end
	else
		parse(com)
	end
end

function Params(line)
	local tbl, temp, quote = {}, {}, nil
	local add = function(input) table.insert(tbl, SKIN:ReplaceVariables(input)) end
	for word in line:gmatch('%S+') do
		if word:match('^"') and not quote then -- Start Quote.
			quote = word:match('^"""') and '"""' or '"'
			if word:match(quote .. '$') then -- Make allowance for parameters using quotes without spaces.
				add(word:match(quote .. '(.+)' .. quote))
				quote = nil
			else
				table.insert(temp, word)
			end
		elseif word:match((quote or '') .. '$') and #temp > 0 then -- Finish quote.
			table.insert(temp, word)
			add(table.concat(temp, ' '):match(quote .. '(.+)' .. quote))
			temp, quote = {}, nil
		elseif quote then -- Between Quotes.
			table.insert(temp, word)
		else
			add(word)
		end
	end
	return tbl
end