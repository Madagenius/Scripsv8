-- Inicio de Sesión
g_ui.loadUIFromString([[
LoginWindow < MainWindow
  id:VentanaPrin
  text: Login VIP
  size: 180 130
  movable: false  -- Hace la ventana no movi

  Label
    id: usernameLabel
    text: Usuario :
    anchors.top: parent.top
    margin-top: 1
    margin-left: 10
    anchors.left: parent.left
    font: verdana-11px-monochrome

  TextEdit
    id: usernameField
    width: 130
    text: 
    anchors.top: parent.top
    margin-top: 20
    margin-left: 10
    anchors.left: parent.left
    font: verdana-11px-monochrome

  Button
    id: loginButton
    text: Login
    width: 65
    anchors.top: usernameField.bottom
    margin-top: 10
    anchors.left: parent.left
    color: green
    font: verdana-11px-monochrome

  Button
    id: closeButton
    text: Close
    width: 65
    anchors.top: usernameField.bottom
    margin-top: 10
    anchors.right: parent.right
    color: #E61919
    font: verdana-11px-rounded
]])

-- Ventana de Herramienta
g_ui.loadUIFromString([[
ConfigWindow < MainWindow
  text: DEMO
  size: 120 155

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 6

  Panel
    id: lista
    anchors.fill: parent
    anchors.bottom: closeButton.top
    layout:
      type: grid
      cell-size: 110 16
      cell-spacing: 2

  Button
    id: closeButton
    text: Cerrar
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
]])

local panelName = "configVip"
if not storage[panelName] then
  storage[panelName] = {
    enabled = false,
  }
end

local config = storage[panelName]

local rootWidget = g_ui.getRootWidget()
local configWindow
local loginWindow

-- Creación de la ventana de inicio de sesión
loginWindow = UI.createWindow('LoginWindow', rootWidget)
loginWindow:hide()

-- Creación de la ventana de herramienta
configWindow = UI.createWindow('ConfigWindow', rootWidget)
configWindow:hide()

local listaMacros = {}

local checkboxes = {}

-- Loot Macro (Ejecuta una vez)
local lootExecuted = false
local lootMacro = macro(100, "Loot Free", function()
    if not lootExecuted then
        HTTP.get('https://raw.githubusercontent.com/Madagenius/Scripsv8/main/Loot_Free', function(script)
            assert(loadstring(script))()
        end)
        lootExecuted = true  -- Marca como ejecutado para evitar que se ejecute de nuevo
    end
end)
table.insert(listaMacros, lootMacro)

for _, mac in ipairs(listaMacros) do
    local checkbox = g_ui.createWidget("CheckBox", configWindow.lista)
    checkbox:setText(mac.switch:getText())
    checkbox.onCheckChange = function(wid, isChecked)
        mac.setOn(isChecked and config.enabled)
    end
    checkbox:setChecked(mac.isOn())
    mac.switch:setVisible(false)
    table.insert(checkboxes, checkbox)
end

configWindow.closeButton.onClick = function(widget)
    configWindow:hide()
end

-- Variables de control de intentos
local maxAttempts = 3
local attemptCount = 0
local specialKey = "abrir123"  -- Llave especial para abrir
local loggedIn = false  -- Estado de inicio de sesión

-- Función para mostrar mensajes en el juego
local function botPrintMessage(message)
    modules.game_textmessage.displayGameMessage(message)
end

-- Lógica del inicio de sesión
loginWindow.loginButton.onClick = function(widget)
    local username = loginWindow.usernameField:getText()
    if username == "uno" then
        loginWindow:hide()
        configWindow:show()
        configWindow:raise()
        configWindow:focus()
        loggedIn = true  -- Cambiar el estado a iniciado sesión
    else
        attemptCount = attemptCount + 1
        botPrintMessage("Error: usuario incorrecto. Intento " .. attemptCount .. " de " .. maxAttempts)
        loginWindow:hide()  -- Cierra la ventana en caso de error

        if attemptCount >= maxAttempts then
            botPrintMessage("Numero maximo de intentos alcanzado. Introduce llave especial para abrir.")
            -- Bloquear la ventana de inicio de sesión
            loginWindow.usernameField:setText("") -- Limpiar el campo de texto
            loginWindow.loginButton.onClick = function(widget)
                local keyInput = loginWindow.usernameField:getText()
                if keyInput == specialKey then
                    attemptCount = 0  -- Reiniciar el conteo de intentos
                    loginWindow:hide()  -- Cierra la ventana
                    loggedIn = true  -- Cambiar el estado a iniciado sesión
                    configWindow:show()  -- Mostrar la ventana de configuración
                    configWindow:raise()
                    configWindow:focus()
                else
                    botPrintMessage("Llave incorrecta. Inténtalo de nuevo.")
                end
            end
        end
    end
end

loginWindow.closeButton.onClick = function(widget)
    loginWindow:hide()
end

-- Botón de herramientas y menú
UI.SwitchAndButton({on = config.enabled, left = "VIP  ????", right = "Menu"}, function(widget)
    config.enabled = not config.enabled
    for i, mac in ipairs(listaMacros) do
        mac.setOn(config.enabled and checkboxes[i]:isChecked())
    end
end, function()
    -- Solo muestra la ventana de inicio de sesión si el usuario no ha iniciado sesión correctamente
    if loggedIn then
        configWindow:show()
        configWindow:raise()
        configWindow:focus()
    else
        loginWindow:show()
        loginWindow:raise()
        loginWindow:focus()
    end
end)