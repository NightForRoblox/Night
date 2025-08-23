repeat task.wait() until game:IsLoaded()
if shared.rust then shared.rust:Uninject() end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
		if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
				getgenv().setthreadidentity = nil
		end
end

local rust
local loadstring = function(...)
		local res, err = loadstring(...)
		if err and rust then
				rust:CreateNotification('Rust', 'Failed to load : '..err, 30, 'alert')
		end
		return res
end

local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
		local suc, res = pcall(function()
				return readfile(file)
		end)
		return suc and res ~= nil and res ~= ''
end

local cloneref = cloneref or function(obj)
		return obj
end

local playersService = cloneref(game:GetService('Players'))
local lplr = playersService.LocalPlayer :: Player
local knit = lplr.PlayerScripts:FindFirstChild('TS') and lplr.PlayerScripts.TS:FindFirstChild('knit') :: ModuleScript?

if knit and identifyexecutor() == 'Delta' and game.PlaceId ~= 6872265039 then
	    local Success, Main
	    local FakeFunc = function() end
	    repeat
	        	Success, Main = pcall(function()
	          			return debug.getupvalue(require(knit).setup, 9)
	        	end)
	        	task.wait()
	    until Success
	    
	    local old; old = hookfunction(debug.getproto, function(func, proto)
		        if func == Main.Controllers.PiggyBankController.KnitStart or func == Main.Controllers.CropController.KnitStart then
		        		return FakeFunc
		        elseif func == FakeFunc then
		        		return FakeFunc
		        end
		        return old(func, proto)
	    end)
end

local function downloadFile(path, func)
		if not isfile(path) then
				local suc, res = pcall(function()
						return game:HttpGet('https://raw.githubusercontent.com/0xEIite/rust/'..readfile('rust/profiles/commit.txt')..'/'..select(1, path:gsub('rust/', '')), true)
				end)
				if not suc or res == '404: Not Found' then
						error(res)
				end
				if path:find('.lua') then
						res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after rust updates.\n'..res
				end
				writefile(path, res)
		end
		return (func or readfile)(path)
end

local function finishLoading()
		rust.Init = nil
		rust:Load()
		task.spawn(function()
			repeat
				rust:Save()
				task.wait(10)
			until not rust.Loaded
		end)
	
		local teleportedServers
		rust:Clean(lplr.OnTeleport:Connect(function()
				if (not teleportedServers) and (not shared.RustIndependent) then
						teleportedServers = true
						local teleportScript = [[
								shared.rustreload = true
								if shared.RustDeveloper then
										loadstring(readfile('rust/loader.lua'), 'loader')()
								else
										loadstring(game:HttpGet('https://raw.githubusercontent.com/0xEIite/rust/'..readfile('rust/profiles/commit.txt')..'/loader.lua', true), 'loader')()
								end
						]]
						if shared.RustDeveloper then
								teleportScript = 'shared.RustDeveloper = true\n'..teleportScript
						end
						if shared.RustCustomProfile then
								teleportScript = 'shared.RustCustomProfile = "'..shared.RustCustomProfile..'"\n'..teleportScript
						end
						rust:Save()
						queue_on_teleport(teleportScript)
				end
		end))
	
		if not shared.rustreload then
				if not rust.Categories then return end
				if rust.Categories.Main.Options['GUI bind indicator'].Enabled then
						rust:CreateNotification('Finished Loading', rust.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(rust.Keybind, ' + '):upper()..' to open GUI', 5)
				end
		end
end

if not isfile('rust/profiles/gui.txt') then
		writefile('rust/profiles/gui.txt', 'rise')
end
local gui = readfile('rust/profiles/gui.txt')

if not isfolder('rust/assets/'..gui) then
		makefolder('rust/assets/'..gui)
end
rust = loadstring(downloadFile('rust/guis/'..gui..'.lua'), 'gui')()
shared.rust = rust

if not shared.RustIndependent then
		loadstring(downloadFile('rust/games/universal.lua'), 'universal')()
		if isfile('rust/games/'..game.PlaceId..'.lua') then
				loadstring(readfile('rust/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
		else
				if not shared.RustDeveloper then
						local suc, res = pcall(function()
								return game:HttpGet('https://raw.githubusercontent.com/0xEIite/rust/'..readfile('rust/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
						end)
						if suc and res ~= '404: Not Found' then
								loadstring(downloadFile('rust/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
				        end
		        end
		end
		finishLoading()
else
		rust.Init = finishLoading
		return rust
end
