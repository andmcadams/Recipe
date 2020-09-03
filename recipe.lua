--<nowiki>

local p = {}

-- convert some used globals to locals to improve performance
local math = math
local string = string
local table = table
local mw = mw
local expr = mw.ext.ParserFunctions.expr

local coins = require('Module:Coins')._amount
local yesno = require('Module:Yesno/new')
local params = require('Module:Paramtest')
local commas = require('Module:Addcommas')
local geprice = require('Module:Exchange')._price
local skillpic = require('Module:SCP')._main
local editbutton = require('Module:Edit button')
local onmain = require('Module:Mainonly').on_main
local currencies = require('Module:Currencies')._amount

local edit = editbutton('? (edit)')

-- Tools that need special handling
local toolsList = {
	['Axe'] = '[[File:Bronze axe.png|link=Axe]]',
}

local facilitiesIcons = {
    ['Anvil'] = '[[File:Anvil icon.png|link=Anvil]]',
    ['Apothecary'] = '[[File:Apothecary icon.png|link=Apothecary]]',
    ['Banner easel'] = '[[File:Banner easel icon.png|link=Banner easel]]',
    ['Barbarian anvil'] = '[[File:Anvil icon.png|link=Anvil]]',
    ['Blast furnace'] = '[[File:Furnace icon.png|link=Blast furnace]]',
    ['Brewery'] = '[[File:Brewery icon.png|link=Brewery]]',
    ['Clay oven'] = '[[File:Cooking range icon.png|link=Clay oven]]',
    ['Cooking range'] = '[[File:Cooking range icon.png|link=Cooking range]]',
    ['Crafting table 1'] = '[[File:Crafting table 1 icon.png|link=Crafting table 1]]',
    ['Crafting table 2'] = '[[File:Crafting table 2 icon.png|link=Crafting table 2]]',
    ['Crafting table 3'] = '[[File:Crafting table 3 icon.png|link=Crafting table 3]]',
    ['Crafting table 4'] = '[[File:Crafting table 4 icon.png|link=Crafting table 4]]',
    ['Dairy churn'] = '[[File:Dairy churn icon.png|link=Dairy churn]]',
    ['Demon lectern'] = '[[File:Demon lectern icon.png|link=Demon lectern]]',
    ['Eagle lectern'] = '[[File:Eagle lectern icon.png|link=Eagle lectern]]',
    ['Fancy Clothes Store'] = '[[File:Clothes shop icon.png|link=Fancy Clothes Store]]',
    ['Farming patch'] = '[[File:Farming patch icon.png|link=Farming/Patch_locations]]',
    ['Furnace'] = '[[File:Furnace icon.png|link=Furnace]]',
    ['Loom'] = '[[File:Loom icon.png|link=Loom]]',
    ['Mahogany demon lectern'] = '[[File:Mahogany demon lectern icon.png|link=Mahogany demon lectern]]',
    ['Mahogany eagle lectern'] = '[[File:Mahogany eagle lectern icon.png|link=Mahogany eagle lectern]]',
    ['Metal Press'] = '[[File:Furnace icon.png|link=Metal Press]]',
    ['Oak lectern'] = '[[File:Oak lectern icon.png|link=Oak lectern]]',
    ['Pluming stand'] = '[[File:Pluming stand icon.png|link=Pluming stand]]',
    ['Pottery wheel'] = '[[File:Pottery wheel icon.png|link=Pottery wheel]]',
    ['Sawmill'] = '[[File:Sawmill icon.png|link=Sawmill]]',
    ['Sandpit'] = '[[File:Sandpit icon.png|link=Sandpit]]',
    ['Shield easel'] = '[[File:Shield easel icon.png|link=Shield easel]]',
    ['Singing bowl'] = '[[File:Singing bowl icon.png|link=Singing bowl]]',
    ['Spinning wheel'] = '[[File:Spinning wheel icon.png|link=Spinning wheel]]',
    ['Tannery'] = '[[File:Tannery icon.png|link=Tannery]]',
    ['Taxidermist'] = '[[File:Taxidermist icon.png|link=Taxidermist]]',
    ['Teak demon lectern'] = '[[File:Teak demon lectern icon.png|link=Teak demon lectern]]',
    ['Teak eagle lectern'] = '[[File:Teak eagle lectern icon.png|link=Teak eagle lectern]]',
    ['Thakkrad Sigmundson'] = '[[File:Tannery icon.png|link=Thakkrad Sigmundson]]',
    ['Water'] = '[[File:Water source icon.png|link=Water]]',
    ['Whetstone'] = '[[File:Whetstone icon.png|link=Whetstone]]',
    ['Windmill'] = '[[File:Windmill icon.png|link=Windmill]]',
    ['Woodcutting stump'] = '[[File:Woodcutting stump icon.png|link=Woodcutting stump]]',
    ['Workbench'] = '[[File:Bench with lathe icon.png|link=Workbench]]'
}

function p.main(frame)
	local args = frame:getParent().args
	
	local function cost_to_number(cost_v, name, currencyName)
		if currencyName ~= nil then
			if cost_v == nil then
				return 1
			elseif tonumber(commas._strip(cost_v),10) then
				return tonumber(commas._strip(cost_v),10)
			elseif tonumber(expr(cost_v),10) then
				return expr(cost_v)
			end
		elseif cost_v == nil then
			return geprice(name)
		elseif string.lower(cost_v) == 'no' then
			return 0
		elseif tonumber(commas._strip(cost_v),10) then
			return tonumber(commas._strip(cost_v),10)
		elseif tonumber(expr(cost_v),10) then
			return expr(cost_v)
		end
		return 0
	end

	local function mat_list(objType)
		local ret_list = {}
		for i=1,11,1 do
			local mat = args[objType..i]
			if mat and params.has_content(mat) then
				local name = mat
				local txt = params.default_to(args[objType..i..'txt'], nil)
				local qty = params.default_to(args[objType..i..'quantity'],'1')
				local img = params.default_to(args[objType..i..'pic'], name..'.png')
				local cost_v = args[objType..i..'cost']
				local currencyName = params.default_to(args[objType..i..'currency'], nil)
				local itemnote = args[objType..i..'itemnote'] or nil
				local qtynote = args[objType..i..'quantitynote'] or nil
				table.insert(ret_list, {
					name = name,
					txt = txt,
					cost = cost_to_number(cost_v, name, currencyName),
					quantity = qty,
					image = string.format('[[File:%s|link=%s]]', img, mat),
					currency_name = currencyName,
					outputnote = itemnote,
					quantitynote = qtynote
				} )
			end
		end
		return ret_list
	end
	
	local function skill_list()
		local ret_list = {}
		for i=1,10,1 do
			local skill = args['skill'..i]
			if skill and params.has_content(skill) then
				local name = skill
				local lvl = params.default_to(args['skill'..i..'lvl'],'1')
				local boost = params.default_to(args['skill'..i..'boostable'],'')
				local exp = params.default_to(args['skill'..i..'exp'],'0')
				table.insert(ret_list, {
					name = name,
					level = lvl,
					boostable = boost,
					experience = exp,
				} )
			end
		end
		return ret_list
	end

	local output = mat_list('output')
	local materials = mat_list('mat')
	local skills = skill_list()

	local members = ''
	if params.has_content(args.members) then
		members = yesno(args.members, true)
		if members then
			members = 'Yes'
		else
			members = 'No'
		end
	end
	
	local nosmw
	if params.has_content(args.nosmw) then
		nosmw = true
	end

	return p._main(frame, args, args.tools, skills, members, args.notes, materials, output, args.facilities, args.ticks, args.ticksnote, nosmw)
end

--
-- Main
--
function p._main(frame, args, tools, skills, members, notes, materials, output, facilities, ticks, ticksnote, nosmw)
	local hasreftag = false
	local function make_row(item_data)
		local classOverride
		local textAlign = 'right'
		if item_data.currency_name ~= nil then
			mat_ttl = currencies(item_data.quantity * item_data.cost, item_data.currency_name)
		elseif item_data.cost == 0 then
			mat_ttl = 'N/A'
			classOverride = 'table-na'
			textAlign = 'center'
		else
			mat_ttl = coins(item_data.quantity * item_data.cost)
		end
		local name = item_data.txt and string.format('[[%s|%s]]', item_data.name, item_data.txt) or string.format('[[%s]]', item_data.name)
		local itemnote = item_data.outputnote and frame:extensionTag{ name = 'ref', content = item_data.outputnote, args = { group = 'r' } } or ''
		if (itemnote ~= '') then hasreftag = true end
		local quantitynote = item_data.quantitynote and frame:extensionTag{ name = 'ref', content = item_data.quantitynote, args = { group = 'r' } } or ''
		if (quantitynote ~= '') then hasreftag = true end
		return mw.html.create('tr')
			:tag('td'):wikitext(item_data.image):done()
			:tag('td'):wikitext(name .. itemnote):done()
			:tag('td'):wikitext(commas._add(item_data.quantity) .. quantitynote):done()
			:tag('td'):addClass(classOverride):css({ ['text-align'] = textAlign }):wikitext(mat_ttl):done(),
				item_data.quantity * item_data.cost,
				note ~= nil
	end
	
	local function toolImages(t)
		local images = {}
				
		if t == nil then
			return 'None'
		end
		
		local spl = mw.text.split(t, ",")
		for _, image_i in ipairs(spl) do
			image_i = mw.text.trim(image_i)
			if toolsList[image_i] then
				table.insert(images, toolsList[trimmed])
			else
				table.insert(images, string.format("[[File:%s.png|link=%s]]", image_i, image_i))
			end
		end
		return table.concat(images)
	end
	
	local function facilityLinks(f)
		local links = {}
		
		if f == nil then
			return 'None'
		end
		
		local spl = mw.text.split(f, ",")
		for _, link_i in ipairs(spl) do
			if facilitiesIcons[link_i] ~= nil then
				table.insert(links, string.format("%s [[%s]]", facilitiesIcons[link_i], link_i))
			else
				table.insert(links, string.format("[[%s]]", link_i))
			end
		end
		return table.concat(links, "<br />")
	end
	local parent = mw.html.create('div')
			:css({width = 'max-content' })

	local requirements = mw.html.create('table')
			:addClass('wikitable align-center-2 align-right-3')
			:css({ width = '100%',
				['margin'] = '0' })
	
	requirements:tag('caption'):wikitext("Requirements"):done()
	local tr = requirements:tag('tr')
		if #skills ~= 0 then
			tr:tag('th'):attr('colspan', 2):wikitext('Skill'):done()
			tr:tag('th'):wikitext('Level'):done()
			tr:tag('th'):wikitext('XP'):done()
		end	
	
	local membersTemplate = edit
	if members == 'Yes' then
		membersTemplate = "[[File:Member icon.png|center|link=Members]]"	
	elseif members == 'No' then
		membersTemplate = "[[File:Free-to-play icon.png|center|link=Free-to-play]]"	
	end

	local unknownBoostableFlag = false
	if #skills ~= 0 then
		for i, v in ipairs(skills) do
			local levelText = v.level
			if(string.lower(v.boostable) == 'yes') then
				levelText = levelText .. ' <sup title="This requirement is boostable" style="cursor:help; text-decoration: underline dotted;">(b)</sup>'
			elseif(string.lower(v.boostable) == 'no') then
				levelText = levelText .. ' <sup title="This requirement is not boostable" style="cursor:help; text-decoration: underline dotted;">(ub)</sup>'
			elseif(tonumber(v.level) > 1) then
				levelText = levelText .. ' <sup title="Unknown whether this requirement is boostable" style="cursor:help; text-decoration: underline dotted;">?</sup>'
				unknownBoostableFlag = true
			end
			requirements:tag('tr')
				:tag('td'):attr('colspan', 2):wikitext(skillpic(v.name, nil, true)):done()
				:tag('td'):wikitext(levelText):done()
				:tag('td'):wikitext(v.experience):done()
		end
	end
	
	if notes ~= nil then
		requirements:tag('tr')
			:tag('td'):attr('colspan', 4):wikitext(notes):done()
	end
	
	local tr = requirements:tag('tr')
	tr:tag('th'):wikitext('Members'):done()
	tr:tag('td'):wikitext(membersTemplate):done()
	tr:tag('th'):attr('title', 'Ticks per action'):wikitext('[[RuneScape clock#Length of a tick|Ticks]]'):done()
	if (ticks or '') == '' then
		tr:tag('td'):wikitext(edit):done()
	elseif string.lower(ticks) == 'na' then
		local classOverride = 'table-na'
		tr:tag('td'):addClass(classOverride):css({ ['text-align'] = center }):wikitext('N/A'):done()
	elseif string.lower(ticks) == 'varies' then
		local note = ''
		if ticksnote ~= nil then
			note = frame:extensionTag{ name='ref', content = ticksnote, args = { group='r' } }
			hasreftag = true
		end
		tr:tag('td'):wikitext('Varies' .. note):done()
	else
		local secs = tonumber(ticks, 10) * 0.6
		local note = ''
		if ticksnote ~= nil then
			note = frame:extensionTag{ name='ref', content = ticksnote, args = { group='r' } }
			hasreftag = true
		end
		tr:tag('td'):attr('title', ticks .. ' ticks (' .. secs .. 's) per action'):wikitext(ticks .. ' (' .. secs .. 's) ' .. note):done()
	end
	
	if tools ~= nil or facilities ~= nil then
		local toolImgs = toolImages(tools)
		local facilityLnks = facilityLinks(facilities)
		requirements:tag('tr')
			:tag('th'):wikitext('Tools'):done()
			:tag('td'):css({ ['text-align'] = 'center' }):wikitext(toolImgs):done()
			:tag('th'):wikitext('Facilities'):done()
			:tag('td'):css({ ['text-align'] = 'center' }):wikitext(facilityLnks):done()
	end
	
	local materialsTable = mw.html.create('table')
			:addClass('wikitable align-center-1 align-right-3 align-right-4')
			:css({ width = '100%',
				['margin-top'] = '-1px' })	

	materialsTable:tag('caption'):wikitext("Materials"):done()
	materialsTable:tag('tr')
		:tag('th'):attr('colspan', 2):wikitext('Item'):done()
		:tag('th'):wikitext('Quantity'):done()
		:tag('th'):wikitext('Cost'):done()
	local currency_costs = {
		['Coins'] = 0 
	}

	for i, v in ipairs(materials) do
		row, row_cost = make_row(v)
		
		if row_cost ~= 0 then
			if v.currency_name ~= nil then
				currency_costs[v.currency_name] = (currency_costs[v.currency_name] and currency_costs[v.currency_name] or 0) + v.quantity * v.cost
			else
				currency_costs['Coins'] = currency_costs['Coins'] + v.quantity * v.cost
			end
		end

		materialsTable:node(row)
	end
	
	if #materials == 0 then
		materialsTable:tag('tr')
			:tag('td'):attr('colspan','5'):css({ ['font-style'] = 'italic', ['text-align'] = 'center' }):wikitext('Materials unlisted '..editbutton()):done()
	else
		local total_cost_breakdown = ''
		for i, v in next, currency_costs, nil do
			total_cost_breakdown = (string.len(total_cost_breakdown) == 0 and total_cost_breakdown or total_cost_breakdown .. '<br />') .. (i == 'Coins' and coins(v) or currencies(v, i))
		end
		materialsTable:tag('tr')
			:tag('th'):attr('colspan', 3):css({['text-align'] = 'right'}):wikitext('Total Cost'):done()
			:tag('td'):css({['text-align'] = 'right'}):wikitext(total_cost_breakdown)
	end
	
	local output_cost = {
		['Coins'] = 0
	}
	for i, v in ipairs(output) do
		row, row_cost, has_row_note = make_row(v)
		
		if row_cost ~= 0 then
			if v.currency_name ~= nil then
				output_cost[v.currency_name] = (output_cost[v.currency_name] and output_cost[v.currency_name] or 0) + v.quantity * v.cost
			else
				output_cost['Coins'] = output_cost['Coins'] + v.quantity * v.cost
			end
		end

		hasreftag = hasreftag or has_output_note
		materialsTable:node(row)
	end

	if output_cost['Coins'] > 0 then
		local profit = output_cost['Coins'] - currency_costs['Coins']
		local note
		if((ticks ~= nil) and (tonumber(ticks) == 0)) then
			if(((6000 * 8) * profit) > 5000000) then -- 8 actions per tick is basically max 0t actions register afaik
				note = ((frame:extensionTag{
					name = 'ref',
					content = 'Due to Grand Exchange prices changing based on trade volume, this profit may not be fully accurate if the components are infrequently traded.',
					args = { group = 'r' }
				}) .. '[[Category:Recipes with questionable profit]]')
			hasreftag = true
			else
				note = ''
			end
		else
			if(((6000 / (tonumber(ticks) or 5)) * profit) > 5000000) then
				note = ((frame:extensionTag{
					name = 'ref',
					content = 'Due to Grand Exchange prices changing based on trade volume, this profit may not be fully accurate if the components are infrequently traded.',
					args = { group = 'r' }
				}) .. '[[Category:Recipes with questionable profit]]')
			hasreftag = true
			else
				note = ''
			end
		end
		
		materialsTable:tag('tr')
			:tag('th'):attr('colspan', 3):css({['text-align'] = 'right'}):wikitext('Profit'):done()
			:tag('td'):css({['text-align'] = 'right'}):wikitext(coins(profit) .. note)
	end
	
	parent:node(requirements)
	parent:node(materialsTable)
	
	if not nosmw then
		local jsonObject = {skills = skills, materials = {}, output = output}
		local materialNames = {}
		for _, v in ipairs(materials) do
			table.insert(jsonObject.materials, {name = v.name, quantity = v.quantity})
			table.insert(materialNames, v.name)
		end
		
		mw.smw.set({
			["Uses material"] = materialNames,
			['Production JSON'] = mw.text.jsonEncode(jsonObject)
		})
	end

	local outro = ''
	if hasreftag then
		outro = '\n' .. frame:extensionTag{ name='references', args = { group='r' } }
	end

	return tostring(parent) .. categories(args, unknownBoostableFlag) .. outro
end

function categories(args, unknownBoostableFlag)
	if not onmain() then
		return ''
	end
	local cats = {}
	
	if unknownBoostableFlag then
		table.insert(cats, '[[Category:Recipes missing boostable]]')
	end
	
	if (args.ticks or '') == '' then
		table.insert(cats, '[[Category:Recipes missing ticks]]')
	end
	
	if args.tools ~= nil then
		table.insert(cats, '[[Category:Recipes that require a tool]]')
	end
	
	if args.facilities ~= nil then
		table.insert(cats, '[[Category:Recipes that use a facility]]')
	end

	return table.concat(cats,'')
end

return p

