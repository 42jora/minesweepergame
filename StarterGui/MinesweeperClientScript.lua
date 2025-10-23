-- Minesweeper Client Script - Создает GUI на клиенте
-- LocalScript для StarterGui

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Ждем RemoteEvent
local remoteEvent = ReplicatedStorage:WaitForChild("MinesweeperOpenEvent", 10)
if not remoteEvent then
        warn("MinesweeperOpenEvent не найден!")
        return
end

-- Настройки сложности
local DIFFICULTIES = {
        {
                name = "Легкий",
                size = 8,
                mines = 10,
                cellSize = 40
        },
        {
                name = "Средний", 
                size = 16,
                mines = 40,
                cellSize = 30
        }
}

-- Глобальные переменные игры
local currentDifficulty = 1 -- По умолчанию легкий
local GRID_SIZE = DIFFICULTIES[currentDifficulty].size
local CELL_SIZE = DIFFICULTIES[currentDifficulty].cellSize
local CELL_PADDING = 3
local MINE_COUNT = DIFFICULTIES[currentDifficulty].mines

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
        mainFrame.Size = UDim2.new(0, 600, 0, 650)
        mainFrame.Position = UDim2.new(0.5, -300, 0.5, -325)
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
        
        -- Панель сложности
        local difficultyFrame = Instance.new("Frame")
        difficultyFrame.Name = "DifficultyFrame"
        difficultyFrame.Size = UDim2.new(1, -20, 0, 40)
        difficultyFrame.Position = UDim2.new(0, 10, 0, 60)
        difficultyFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        difficultyFrame.BorderSizePixel = 0
        difficultyFrame.Parent = mainFrame
        
        -- Выбор сложности
        local difficultyDropdown = Instance.new("TextButton")
        difficultyDropdown.Name = "DifficultyDropdown"
        difficultyDropdown.Size = UDim2.new(0, 150, 0, 30)
        difficultyDropdown.Position = UDim2.new(0, 5, 0, 5)
        difficultyDropdown.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        difficultyDropdown.BorderSizePixel = 0
        difficultyDropdown.Text = DIFFICULTIES[currentDifficulty].name
        difficultyDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        difficultyDropdown.TextScaled = true
        difficultyDropdown.Font = Enum.Font.SourceSans
        difficultyDropdown.Parent = difficultyFrame
        
        -- Информационная панель
        local infoFrame = Instance.new("Frame")
        infoFrame.Name = "InfoFrame"
        infoFrame.Size = UDim2.new(1, -20, 0, 80)
        infoFrame.Position = UDim2.new(0, 10, 0, 110)
        infoFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        infoFrame.BorderSizePixel = 0
        infoFrame.Parent = mainFrame
        
        -- Счетчик мин
        local mineCounter = Instance.new("TextLabel")
        mineCounter.Name = "MineCounter"
        mineCounter.Size = UDim2.new(0.3, -5, 1, 0)
        mineCounter.Position = UDim2.new(0, 0, 0, 0)
        mineCounter.BackgroundTransparency = 1
        mineCounter.Text = "Мины: " .. MINE_COUNT
        mineCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
        mineCounter.TextScaled = true
        mineCounter.Font = Enum.Font.SourceSans
        mineCounter.Parent = infoFrame
        
        -- Таймер
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Name = "TimerLabel"
        timerLabel.Size = UDim2.new(0.3, -5, 0, 25)
        timerLabel.Position = UDim2.new(0.35, 0, 0, -10)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = "Время: 000"
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.TextScaled = true
        timerLabel.Font = Enum.Font.SourceSans
        timerLabel.Parent = infoFrame
        
        -- Кнопка сброса (смайлик)
        local resetButton = Instance.new("TextButton")
        resetButton.Name = "ResetButton"
        resetButton.Size = UDim2.new(0, 50, 0, 50)
        resetButton.Position = UDim2.new(0.5, -25, 0, 20)
        resetButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        resetButton.BorderSizePixel = 2
        resetButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
        resetButton.Text = "🙂"
        resetButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        resetButton.TextScaled = true
        resetButton.Font = Enum.Font.SourceSans
        resetButton.Parent = infoFrame
        
  
        -- Фрейм для игрового поля
        local gridFrame = Instance.new("Frame")
        gridFrame.Name = "GridFrame"
        gridFrame.Size = UDim2.new(0, GRID_SIZE * (CELL_SIZE + CELL_PADDING), 0, GRID_SIZE * (CELL_SIZE + CELL_PADDING))
        gridFrame.Position = UDim2.new(0.5, -(GRID_SIZE * (CELL_SIZE + CELL_PADDING)) / 2, 0, 200)
        gridFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        gridFrame.BorderSizePixel = 0
        gridFrame.Parent = mainFrame
        
        -- Создаем ячейки
        local cells = {}
        local gameActive = false
        local firstClick = true -- Отслеживание первого клика
        local minePositions = {}
        local revealedCells = {} -- Отслеживание открытых ячеек
        local startTime = 0
        local elapsedTime = 0
        local timerConnection = nil
        
        -- Функция обновления таймера
        local function updateTimer()
                if gameActive then
                        elapsedTime = math.floor(tick() - startTime)
                        timerLabel.Text = "Время: " .. string.format("%03d", elapsedTime)
                end
        end
        
        -- Функция остановки таймера
        local function stopTimer()
                if timerConnection then
                        timerConnection:Disconnect()
                        timerConnection = nil
                end
        end
        
        -- Функция генерации мин (изменена для генерации после первого клика)
        local function generateMines(excludeRow, excludeCol)
                minePositions = {}
                local mineCount = 0
                
                while mineCount < MINE_COUNT do
                        local row = math.random(1, GRID_SIZE)
                        local col = math.random(1, GRID_SIZE)
                        
                        -- Исключаем первую нажатую клетку и ее соседей от генерации мин
                        local isExcluded = false
                        for i = -1, 1 do
                                for j = -1, 1 do
                                        if row == excludeRow + i and col == excludeCol + j then
                                                isExcluded = true
                                                break
                                        end
                                end
                                if isExcluded then break end
                        end
                        
                        if not isExcluded then
                                local key = row .. "_" .. col
                                if not minePositions[key] then
                                        minePositions[key] = true
                                        mineCount = mineCount + 1
                                end
                        end
                end
        end
        
        -- Функция создания сетки (вынесена наверх для правильной области видимости)
        local function createGrid()
                -- Очищаем старые ячейки
                for _, cellRow in pairs(cells) do
                        if type(cellRow) == "table" then
                                for _, cell in pairs(cellRow) do
                                        if cell and cell.Destroy then
                                                cell:Destroy()
                                        end
                                end
                        end
                end
                cells = {}
                revealedCells = {} -- Очищаем открытые ячейки
                
                -- НЕ генерируем мины здесь - они будут сгенерированы после первого клика
                minePositions = {}
                
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
                                        local cellRow = cell:GetAttribute("Row")
                                        local cellCol = cell:GetAttribute("Col")
                                        local key = cellRow .. "_" .. cellCol
                                        
                                        -- Если ячейка уже открыта, не делаем ничего
                                        if revealedCells[key] then
                                                return
                                        end
                                        
                                        -- Проверяем первый клик
                                        if firstClick then
                                                firstClick = false
                                                gameActive = true
                                                
                                                -- Генерируем мины, исключая первую клетку и ее соседей
                                                generateMines(cellRow, cellCol)
                                                
                                                -- Запускаем таймер
                                                startTime = tick()
                                                elapsedTime = 0
                                                timerConnection = RunService.Heartbeat:Connect(updateTimer)
                                                
                                                -- Показываем сообщение о начале игры
                                                StarterGui:SetCore("ChatMakeSystemMessage", {
                                                        Text = "🎮 Игра началась! Найдите все мины!";
                                                        Color = Color3.fromRGB(0, 255, 0);
                                                        Font = Enum.Font.SourceSans;
                                                })
                                        end
                                        
                                        if not gameActive then
                                                return
                                        end
                                        
                                        if minePositions[key] then
                                                -- Попали на мину
                                                cell.BackgroundColor3 = COLORS.MINE
                                                cell.Text = "💣"
                                                cell.TextColor3 = Color3.fromRGB(0, 0, 0)
                                                gameActive = false
                                                stopTimer()
                                                resetButton.Text = "😵"
                                                
                                                -- Показываем все мины
                                                for r = 1, GRID_SIZE do
                                                        for c = 1, GRID_SIZE do
                                                                local mineKey = r .. "_" .. c
                                                                if minePositions[mineKey] and cells[r] and cells[r][c] then
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
                                                local totalSafeCells = GRID_SIZE * GRID_SIZE - MINE_COUNT
                                                
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
                                                        stopTimer()
                                                        resetButton.Text = "😎"
                                                        StarterGui:SetCore("ChatMakeSystemMessage", {
                                                                Text = "🎉 ПОБЕДА! Вы открыли все безопасные ячейки! Время: " .. elapsedTime .. " сек.";
                                                                Color = Color3.fromRGB(0, 255, 0);
                                                                Font = Enum.Font.SourceSans;
                                                        })
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
        
        -- Функция сброса игры (вынесена после createGrid)
        local function resetGame()
                gameActive = false
                firstClick = true -- Сбрасываем флаг первого клика
                stopTimer()
                resetButton.Text = "🙂"
              
                timerLabel.Text = "Время: 000"
                createGrid()
        end
        
        -- Обработчик кнопки сброса
        resetButton.MouseButton1Click:Connect(function()
                resetGame()
        end)
        
        -- Обработчик изменения сложности
        local function changeDifficulty()
                currentDifficulty = currentDifficulty % 2 + 1 -- Циклический перебор 1->2->1
                GRID_SIZE = DIFFICULTIES[currentDifficulty].size
                CELL_SIZE = DIFFICULTIES[currentDifficulty].cellSize
                MINE_COUNT = DIFFICULTIES[currentDifficulty].mines
                
                difficultyDropdown.Text = DIFFICULTIES[currentDifficulty].name
                mineCounter.Text = "Мины: " .. MINE_COUNT
                
                -- Обновляем размер игрового поля
                gridFrame.Size = UDim2.new(0, GRID_SIZE * (CELL_SIZE + CELL_PADDING), 0, GRID_SIZE * (CELL_SIZE + CELL_PADDING))
                gridFrame.Position = UDim2.new(0.5, -(GRID_SIZE * (CELL_SIZE + CELL_PADDING)) / 2, 0, 200)
                
                -- Сбрасываем игру
                resetGame()
        end
        
        difficultyDropdown.MouseButton1Click:Connect(changeDifficulty)
        
        -- Создаем начальное игровое поле
        createGrid()
        
        -- Показываем сообщение об успешном создании
        StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "✅ Сапер открыт! Выберите сложность и нажмите на любую клетку для начала";
                Color = Color3.fromRGB(0, 255, 0);
                Font = Enum.Font.SourceSans;
        })
        
        print("Клиент: GUI успешно создан")
end

-- Подключаем обработчик RemoteEvent
remoteEvent.OnClientEvent:Connect(function()
        createMinesweeperGUI()
end)
