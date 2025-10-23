-- Simple Click Part Client - Правильное клиентское решение
-- Server Script для создания GUI

local part = script.Parent
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Настройка part
part.Anchored = true
part.CanCollide = true
part.CanTouch = true
part.Size = Vector3.new(6, 6, 6)
part.BrickColor = BrickColor.new("Bright green")
part.Material = Enum.Material.Neon

-- Добавляем свет
local light = Instance.new("PointLight")
light.Brightness = 2
light.Color = Color3.fromRGB(0, 255, 0)
light.Range = 20
light.Parent = part

-- Создаем RemoteEvent для связи с клиентом
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "MinesweeperOpenEvent"
remoteEvent.Parent = ReplicatedStorage

-- Создаем ClickDetector
local clickDetector = Instance.new("ClickDetector")
clickDetector.Name = "GameClickDetector"
clickDetector.MaxActivationDistance = 50
clickDetector.Parent = part

-- Функция открытия игры (серверная часть)
local function openGame(player)
	print("Сервер: Запрос на открытие Сапера от:", player.Name)
	
	-- Отправляем сигнал клиенту создать GUI
	remoteEvent:FireClient(player)
end

-- Подключаем клик
clickDetector.MouseClick:Connect(openGame)

-- Дополнительно - пробуем и касание
part.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		print("Сервер: Касание от:", player.Name)
		wait(1) -- Задержка чтобы не спамить
		openGame(player)
	end
end)

print("Simple Click Part Server initialized!")