function Initialize()
	File = ReadIni(SKIN:GetVariable('@') .. 'Run.cfg')
end

function ReadIni(inputfile)
	local file = io.open(inputfile, 'r')
	local tbl = {}
	local section
	if file then
		local strip = function(input, match) return string.match(input, '^%s*('..(match or '.-')..')%s*$') end
		for line in file:lines() do
			if not string.match(line, '^;')then
				local key,command = string.match(line, '^([^=]+)=(.+)')
				if string.match(line, '^%s-%[.+') then
					section = string.lower(string.match(line, '^%s-%[([^%]]+)'))
					if not tbl[section] then tbl[section] = {} end
				elseif key and command and section then
					tbl[section][strip(string.lower(key), '%S*')]=strip(command)
				end
			end
		end
		io.close(file)
	end
	return tbl
end

function Run()
	local command = SKIN:GetVariable('Run')
	local func = string.match(command, '^%s-(%a+)')
	
	if string.len(func or '') > 0 then
		local args = Params(string.match(command, '^%s-%a+ (.+)') or '')
		if string.match(command, '^=.+') then
			local value = SKIN:ParseFormula('('..string.match(command, '^=(.+)')..')')
			Output(value)
		elseif File.search[func] and #args > 0 then -- Search
			local text = table.concat(args, '%%20')
			local line = string.gsub(File.search[func], '\\1', text)
			SKIN:Bang('"'..line..'"')
		elseif func == 'web' and #args > 0 then -- Web
			local tbl = {}
			for word in string.gmatch(table.concat(args,'%%20'), '[^.]+') do table.insert(tbl, word) end
			SKIN:Bang('"http://'..(#tbl >= 3 and '' or 'www.')..table.concat(tbl,'.')..(#tbl >= 2 and '"' or '.com"'))
		elseif File.macros[func] and #args > 0 then -- Custom
			if string.match(File.macros[func],'\\%d') then
				local test = 0
				for num in string.gmatch(File.macros[func], '\\(%d)') do if tonumber(num) > test then test=tonumber(num) end end
				if #args < test then
					Output(func..': Not Enough Parameters')
				else
					local err = false
					local text = string.gsub(File.macros[func], '\\(%d)(%b{})', function(num, list)
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
						Send(text)
					else
						Output(func..': Invalid Parameter')
					end
				end
			else
				Send(File.macros[string.lower(command)] or command)
			end
		elseif string.match(string.lower(command), '^http://') then -- Http
			Send('"'..command..'"')
		else -- Basic
			Send(File.macros[string.lower(command)] or command)
		end
	end
	SKIN:Bang('!Update')
end

function Send(com)
	local lbang = string.match(com, '^%s-!(%a+)')
	local parms = string.match(com, '^%s-!%a+ (.+)')
	
	local tbl = {
		writetofile = function()
			--!WriteToFile File Text Match
			local tbl = Params(parms)
			if #tbl >= 2 then
				local hFile = io.open(SKIN:MakePathAbsolute(tbl[1]), 'r')
				if hFile then
					local text = hFile:read('*all')
					io.close(hFile)
					local rfile = function(...)
						hFile = io.open(SKIN:MakePathAbsolute(tbl[1]), 'w')
						hFile:write(unpack(arg))
						io.close(hFile)
					end
					if #tbl == 3 then
						local start = string.find(string.lower(text), string.lower(tbl[3]))
						if start then
							rfile(string.sub(text, 1, start-1), tbl[2], string.sub(text, start))
						else
							rfile(text, string.len(text)>0 and '\n' or '', tbl[2])
						end
					else
						rfile(text, string.len(text)>0 and '\n' or '', tbl[2])
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
	for word in string.gmatch(line, '%S+') do
		if string.match(word, '"$') and #temp > 0 then
			table.insert(temp, word)
			local nword = string.match(table.concat(temp, ' '), '"(.+)"')
			table.insert(tbl, SKIN:ReplaceVariables(nword))
			temp = {}
		elseif string.match(word, '^"') or #temp > 0 then
			table.insert(temp, word)
		else
			table.insert(tbl, SKIN:ReplaceVariables(word))
		end
	end
	return tbl
end

function Output(outtext)
	SKIN:Bang('!EnableMeasure', 'Reset')
	SKIN:Bang('!SetVariable', 'Output', outtext)
end