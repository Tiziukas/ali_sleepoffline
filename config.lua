Config = {}

-- Basic Settings
Config.Debug = false -- Enable/disable debug messages
Config.Locale = 'de' -- (de/en)

-- Ped Settings
Config.PedTimeout = 15 -- Time in minutes after which a sleeping ped is removed
Config.PedCheckInterval = 1 -- Interval in minutes to check for old peds
Config.PedOffset = -1.0 -- Z-offset for the ped position (height above the ground)

-- Text Settings
Config.TextSettings = {
    Font = 4, -- Font ID for the 3D text
    Scale = 0.55, -- Base scaling of the 3D text
    Color = {r = 255, g = 255, b = 255, a = 255}, -- Text color (RGB + Alpha)
    DrawDistance = 15.0, -- Maximum distance at which the text is displayed
}

-- Animation Settings
Config.Animation = {
    Dict = "timetable@tracy@sleep@", -- Animation dictionary
    Name = "idle_c", -- Animation name
    Flag = 1, -- Animation flag
    BlendIn = 8.0, -- Transition speed into the animation
    BlendOut = -8.0, -- Transition speed out of the animation
}

-- Name Display Settings
Config.NameDisplay = {
    Enabled = true, -- Enable/disable name display
    MaskLastname = true, -- Mask last name (e.g., "Mustermann" becomes "Mu*******")
    MaskLength = 2, -- Number of visible characters for the masked last name
    Format = "~y~Player Sleeping\n~w~Name: %s" -- Format of the name display (%s is replaced with the name)
}

-- MySQL Settings
Config.MySQL = {
    Tables = {
        Users = "users", -- Name of the users table
        Fields = {
            Identifier = "identifier", -- Column name for the player ID
            Skin = "skin", -- Column name for skin data
            Firstname = "firstname", -- Column name for the first name
            Lastname = "lastname" -- Column name for the last name
        }
    }
}

-- Permissions
Config.Permissions = {
    FakeCommand = "admin",
    FakeCommandName = "fakesleep"
}

-- Localization
Config.Locales = {
    ['de'] = {
        ['sleeping'] = 'Player Sleeping',
        ['name'] = 'Name: %s',
        ['unknown'] = 'Unknown'
    },
    ['en'] = {
        ['sleeping'] = 'Player Sleeping',
        ['name'] = 'Name: %s',
        ['unknown'] = 'Unknown'
    }
}
