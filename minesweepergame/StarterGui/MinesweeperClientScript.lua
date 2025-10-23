-- Minesweeper Client Script - Создает GUI на клиенте
-- LocalScript для StarterGui

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Ждем RemoteEvent
local remoteEvent = ReplicatedStorage:WaitForChild("MinesweeperOpenEvent", 10)
if not remoteEvent then
        warn("MinesweeperOpenEvent не найден!")
        return
end

-- Игровые константы
local GRID_SIZE = 8
local CELL_SIZE = 40
local CELL_PADDING = 3

-- Цвета для ячеек
local COLORS = {
        HIDDEN = Color3.fromRGB(200, 200, 200),
        REVEALED = Color3.fromRGB(240, 240, 240),
        MINE = Color3.fromRGB(255, 100, 100),
        FLAG = Color3.fromRGB(255, 200, 0),
        TEXT = {
                [1] = Color3.fromRGB(0, 0, 255),      -- Синий
                [2] = Color3.fromRGB(0, 128, 0),      -- Зеленый
                [3] = Color3.fromRGB(255, 0, 0),      -- Красный
                [4] = Color3.fromRGB(0, 0, 128),      -- Темно-синий
                [5] = Color3.fromRGB(128, 0, 0),      -- Темно-красный
                [6] = Color3.fromRGB(0, 128, 128),    -- Бирюзовый
                [7] = Color3.fromRGB(0, 0, 0),        -- Черный
                [8] = Color3.fromRGB(128, 128, 128)   -- Серый
        }
}

-- Функция для подсчета мин вокруг ячейки
local function countAdjacentMines(row, col, minePositions)
        local count = 0
        
        for i = -1, 1 do
                for j = -1, 1 do
                        if i == 0 and j == 0 then continue end
                        
                        local newRow = row + i
                        local newCol = col + j
                        
                        if newRow >= 1 and newRow <= GRID_SIZE and newCol >= 1 and newCol <= GRID_SIZE then
                                local key = newRow .. "_" .. newCol
                                if minePositions[key] then
                                        count = count + 1
                                end
                        end
                end
        end
        
        return count
end

-- Функция для рекурсивного открытия пустых ячеек
local function revealEmptyCells(row, col, minePositions, cells, revealed)
        local key = row .. "_" .. col
        
        -- Проверяем границы
        if row < 1 or row > GRID_SIZE or col < 1 or col > GRID_SIZE then
                return
        end
        
        -- Если ячейка уже открыта или это мина, выходим
        if revealed[key] or minePositions[key] then
                return
        end
        
        -- Открываем ячейку
        revealed[key] = true
        
        -- Получаем количество мин вокруг
        local adjacentMines = countAdjacentMines(row, col, minePositions)
        
        if cells[row] and cells[row][col] then
                cells[row][col].BackgroundColor3 = COLORS.REVEALED
                
                if adjacentMines > 0 then
                        -- Показываем цифру
                        cells[row][col].Text = tostring(adjacentMines)
                        cells[row][col].TextColor3 = COLORS.TEXT[adjacentMines] or Color3.fromRGB(0, 0, 0)
                else
                        -- Пустая ячейка - открываем соседние
                        cells[row][col].Text = ""
                        
                        -- Рекурсивно открываем все соседние ячейки
                        for i = -1, 1 do
                                for j = -1, 1 do
                                        if i == 0 and j == 0 then continue end
                                        revealEmptyCells(row + i, col + j, minePositions, cells, revealed)
                                end
                        end
                end
        end
end

-- Функция создания GUI
local function createMinesweeperGUI()
        print("Клиент: Создаем GUI для Сапера")
        
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Удаляем старый GUI если есть
        local oldGui = playerGui:FindFirstChild("MinesweeperGUI")
        if oldGui then
                oldGui:Destroy()
        end
        
        -- Создаем основной ScreenGui
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MinesweeperGUI"
        screenGui.Parent = playerGui
        
        -- Основной фрейм
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 400, 0, 500)
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
        mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "САПЕР"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.SourceSansBold
        title.Parent = mainFrame
        
        -- Кнопка закрытия
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0, 5)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        closeButton.BorderSizePixel = 0
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.SourceSans
        closeButton.Parent = mainFrame
        
        closeButton.MouseButton1Click:Connect(function()
                screenGui:Destroy()
        end)
        
        -- Информационная панель
        local infoFrame = Instance.new("Frame")
        infoFrame.Name = "InfoFrame"
        infoFrame.Size = UDim2.new(1, -20, 0, 40)
        infoFrame.Position = UDim2.new(0, 10, 0, 60)
        infoFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        infoFrame.BorderSizePixel = 0
        infoFrame.Parent = mainFrame
        
        -- Счетчик мин
        local mineCounter = Instance.new("TextLabel")
        mineCounter.Name = "MineCounter"
        mineCounter.Size = UDim2.new(0.5, -5, 1, 0)
        mineCounter.Position = UDim2.new(0, 0, 0, 0)
        mineCounter.BackgroundTransparency = 1
        mineCounter.Text = "Мины: 10"
        mineCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
        mineCounter.TextScaled = true
        mineCounter.Font = Enum.Font.SourceSans
        mineCounter.Parent = infoFrame
        
        -- Кнопка начала игры
        local startButton = Instance.new("TextButton")
        startButton.Name = "StartButton"
        startButton.Size = UDim2.new(0, 120, 0, 35)
        startButton.Position = UDim2.new(0.5, -60, 0, 110)
        startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startButton.BorderSizePixel = 0
        startButton.Text = "Начать игру"
        startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        startButton.TextScaled = true
        startButton.Font = Enum.Font.SourceSans
        startButton.Parent = mainFrame
        
        -- Фрейм для игрового поля
        local gridFrame = Instance.new("Frame")
        gridFrame.Name = "GridFrame"
        gridFrame.Size = UDim2.new(0, GRID_SIZE * (CELL_SIZE + CELL_PADDING), 0, GRID_SIZE * (CELL_SIZE + CELL_PADDING))
        gridFrame.Position = UDim2.new(0.5, -(GRID_SIZE * (CELL_SIZE + CELL_PADDING)) / 2, 0, 160)
        gridFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        gridFrame.BorderSizePixel = 0
        gridFrame.Parent = mainFrame
        
        -- Создаем ячейки
        local cells = {}
        local gameActive = false
        local minePositions = {}
        local revealedCells = {} -- Отслеживание открытых ячеек
        
        local function createGrid()
                -- Очищаем старые ячейки
                for _, cell in pairs(cells) do
                        cell:Destroy()
                end
                cells = {}
                revealedCells = {} -- Очищаем открытые ячейки
                
                -- Генерируем мины
                minePositions = {}
                local mineCount = 0
                
                while mineCount < 10 do
                        local row = math.random(1, GRID_SIZE)
                        local col = math.random(1, GRID_SIZE)
                        
                        local key = row .. "_" .. col
                        if not minePositions[key] then
                                minePositions[key] = true
                                mineCount = mineCount + 1
                        end
                end
                
                -- Создаем ячейки
                for row = 1, GRID_SIZE do
                        cells[row] = {}
                        for col = 1, GRID_SIZE do
                                local cell = Instance.new("TextButton")
                                cell.Name = "Cell_" .. row .. "_" .. col
                                cell.Size = UDim2.new(0, CELL_SIZE, 0, CELL_SIZE)
                                cell.Position = UDim2.new(0, (col - 1) * (CELL_SIZE + CELL_PADDING), 0, (row - 1) * (CELL_SIZE + CELL_PADDING))
                                cell.BackgroundColor3 = COLORS.HIDDEN
                                cell.BorderSizePixel = 1
                                cell.BorderColor3 = Color3.fromRGB(150, 150, 150)
                                cell.Text = ""
                                cell.TextScaled = true
                                cell.Font = Enum.Font.SourceSans
                                cell.Parent = gridFrame
                                
                                -- Сохраняем информацию о ячейке
                                cell:SetAttribute("Row", row)
                                cell:SetAttribute("Col", col)
                                
                                -- Обработчики кликов
                                cell.MouseButton1Click:Connect(function()
                                        if gameActive then
                                                local cellRow = cell:GetAttribute("Row")
                                                local cellCol = cell:GetAttribute("Col")
                                                local key = cellRow .. "_" .. cellCol
                                                
                                                -- Если ячейка уже открыта, не делаем ничего
                                                if revealedCells[key] then
                                                        return
                                                end
                                                
                                                if minePositions[key] then
                                                        -- Попали на мину
                                                        cell.BackgroundColor3 = COLORS.MINE
                                                        cell.Text = "💣"
                                                        cell.TextColor3 = Color3.fromRGB(0, 0, 0)
                                                        gameActive = false
                                                        
                                                        -- Показываем все мины
                                                        for r = 1, GRID_SIZE do
                                                                for c = 1, GRID_SIZE do
                                                                        local mineKey = r .. "_" .. c
                                                                        if minePositions[mineKey] and cells[r][c] then
                                                                                cells[r][c].BackgroundColor3 = COLORS.MINE
                                                                                cells[r][c].Text = "💣"
                                                                                cells[r][c].TextColor3 = Color3.fromRGB(0, 0, 0)
                                                                        end
                                                                end
                                                        end
                                                        
                                                        -- Показываем сообщение о проигрыше
                                                        StarterGui:SetCore("ChatMakeSystemMessage", {
                                                                Text = "💥 Игра окончена! Вы попали на мину!";
                                                                Color = Color3.fromRGB(255, 0, 0);
                                                                Font = Enum.Font.SourceSans;
                                                        })
                                                else
                                                        -- Безопасная ячейка - открываем ее
                                                        revealEmptyCells(cellRow, cellCol, minePositions, cells, revealedCells)
                                                        
                                                        -- Проверяем победу
                                                        local safeCellsOpened = 0
                                                        local totalSafeCells = GRID_SIZE * GRID_SIZE - 10
                                                        
                                                        for r = 1, GRID_SIZE do
                                                                for c = 1, GRID_SIZE do
                                                                        local checkKey = r .. "_" .. c
                                                                        if revealedCells[checkKey] then
                                                                                safeCellsOpened = safeCellsOpened + 1
                                                                        end
                                                                end
                                                        end
                                                        
                                                        if safeCellsOpened == totalSafeCells then
                                                                gameActive = false
                                                                StarterGui:SetCore("ChatMakeSystemMessage", {
                                                                        Text = "🎉 ПОБЕДА! Вы открыли все безопасные ячейки!";
                                                                        Color = Color3.fromRGB(0, 255, 0);
                                                                        Font = Enum.Font.SourceSans;
                                                                })
                                                        end
                                                end
                                        end
                                end)
                                
                                cell.MouseButton2Click:Connect(function()
                                        if gameActive then
                                                local cellRow = cell:GetAttribute("Row")
                                                local cellCol = cell:GetAttribute("Col")
                                                local key = cellRow .. "_" .. cellCol
                                                
                                                -- Нельзя ставить флаг на открытую ячейку
                                                if revealedCells[key] then
                                                        return
                                                end
                                                
                                                if cell.Text == "🚩" then
                                                        cell.Text = ""
                                                        cell.BackgroundColor3 = COLORS.HIDDEN
                                                else
                                                        cell.Text = "🚩"
                                                        cell.BackgroundColor3 = COLORS.FLAG
                                                        cell.TextColor3 = Color3.fromRGB(255, 255, 255)
                                                end
                                        end
                                end)
                                
                                cells[row][col] = cell
                        end
                end
        end
        
        -- Обработчик начала игры
        startButton.MouseButton1Click:Connect(function()
                gameActive = true
                startButton.Visible = false
                
                -- Создаем игровое поле
                createGrid()
                
                -- Показываем сообщение
                StarterGui:SetCore("ChatMakeSystemMessage", {
                        Text = "🎮 Игра началась! Найдите все мины!";
                        Color = Color3.fromRGB(0, 255, 0);
                        Font = Enum.Font.SourceSans;
                })
        end)
        
        -- Показываем сообщение об успешном создании
        StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "✅ Сапер открыт! Нажмите 'Начать игру'";
                Color = Color3.fromRGB(0, 255, 0);
                Font = Enum.Font.SourceSans;
        })
        
        print("Клиент: GUI успешно создан")
end

-- Подключаем обработчик RemoteEvent
remoteEvent.OnClientEvent:Connect(function()
        createMinesweeperGUI()
end)

print("Minesweeper Client Script initialized!")