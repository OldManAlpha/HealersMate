HMUIProfile = {}

-- The base template for profile creation
local DEFAULT_PROFILE_VALUES = {}

local HM
local util

function HMUIProfile:New(base)
    HM = HealersMate -- Need to do this in the constructor or else it doesn't exist yet
    util = HMUtil
    local obj = util.CloneTable(base or DEFAULT_PROFILE_VALUES, true)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function HMUIProfile.CreatePositionedObject()
    local obj = {}
    obj.AlignmentH = "CENTER" -- LEFT, CENTER, RIGHT
    obj.AlignmentV = "CENTER" -- TOP, CENTER, BOTTOM
    obj.PaddingH = 4
    obj.PaddingV = 4
    obj.OffsetX = 0
    obj.OffsetY = 0
    obj.Anchor = "Health Bar" -- Health Bar, Power Bar, Button, Container
    obj.Opacity = 100
    obj.GetOffsetX = function(self)
        if self.AlignmentH == "LEFT" then
            return self.PaddingH + self.OffsetX
        elseif self.AlignmentH == "RIGHT" then
            return -self.PaddingH + self.OffsetX
        end
        return self.OffsetX
    end
    obj.GetOffsetY = function(self)
        if self.AlignmentV == "TOP" then
            return -self.PaddingV + self.OffsetY
        elseif self.AlignmentV == "BOTTOM" then
            return self.PaddingV + self.OffsetY
        end
        return self.OffsetY
    end
    obj.GetAlpha = function(self)
        return self.Opacity / 100
    end
    obj.ApplyPredefined = function(self, predefined)
        if predefined then
            for key, value in pairs(predefined) do
                self[key] = value
            end
        end
    end
    return obj
end

function HMUIProfile.CreateSizedObject(predefined)
    local obj = HMUIProfile.CreatePositionedObject()
    obj.Width = 24
    obj.Height = 24
    obj:ApplyPredefined(predefined)
    return obj
end

function HMUIProfile.CreateTextObject(predefined)
    local obj = HMUIProfile.CreatePositionedObject()
    obj.FontSize = 12
    obj.MaxWidth = 1000
    obj:ApplyPredefined(predefined)
    return obj
end

function HMUIProfile:GetHeight()
    local totalHeight = self.HealthBarHeight + self.PowerBarHeight + self.TrackedAurasHeight + self.BarsOffsetY
    return totalHeight
end

function HMUIProfile.SetDefaults()
    local createTextObject = HMUIProfile.CreateTextObject
    local createSizedObject = HMUIProfile.CreateSizedObject

    local profile = DEFAULT_PROFILE_VALUES

    profile.Width = 150

    profile.BarsOffsetY = 0

    profile.HealthBarHeight = 24
    profile.HealthBarColor = "Green To Red" -- "Class", "Green", "Green To Red"
    profile.HealthBarStyle = "Blizzard Raid" -- "Blizzard", "Blizzard Raid"

    profile.HealthDisplay = "Health" -- "Health", "Health/Max Health", "% Health", "Hidden"
    profile.MissingHealthDisplay = "-Health" -- "Hidden", "-Health", "-% Health"
    profile.AlwaysShowMissingHealth = false
    profile.ShowEnemyMissingHealth = false
    profile.MissingHealthInline = false
    profile.HealthTexts = {}
    profile.HealthTexts.Normal = createTextObject({
        ["FontSize"] = 12,
        ["AlignmentV"] = "CENTER",
        ["AlignmentH"] = "RIGHT"
    })
    -- Only used when MissingHealthInline is false
    profile.HealthTexts.WithMissing = createTextObject({
        ["FontSize"] = 11,
        ["AlignmentV"] = "TOP",
        ["AlignmentH"] = "RIGHT",
        ["PaddingV"] = 0
    })
    -- Only used when MissingHealthInline is false
    profile.HealthTexts.Missing = createTextObject({
        ["FontSize"] = 13,
        ["AlignmentV"] = "BOTTOM",
        ["AlignmentH"] = "RIGHT",
        ["PaddingV"] = 0,
        ["Color"] = {1, 0.4, 0.4}
    })

    profile.AlertPercent = 100
    profile.NotAlertedOpacity = 60

    profile.PowerBarHeight = 12
    profile.PowerBarStyle = "Blizzard" -- "Blizzard", "Blizzard Raid"
    profile.PowerText = createTextObject({
        ["FontSize"] = 10,
        ["AlignmentH"] = "RIGHT",
        ["Anchor"] = "Power Bar"
    })
    profile.PowerDisplay = "Power" -- "Power", "Power/Max Power", "% Power", "Hidden"

    profile.NameText = createTextObject({
        ["FontSize"] = 12,
        ["AlignmentH"] = "LEFT",
        ["Color"] = "Class",
        ["MaxWidth"] = 105
    })
    profile.NameDisplay = "Name" -- Unimplemented
    -- "Name", "Name (Class)"

    profile.OutOfRangeOpacity = 50
    profile.RangeText = createTextObject({
        ["FontSize"] = 9,
        ["AlignmentV"] = "TOP",
        ["PaddingV"] = 0
    })
    profile.LineOfSightIcon = createSizedObject({
        ["Width"] = 24,
        ["Height"] = 24,
        ["AlignmentH"] = "CENTER",
        ["AlignmentV"] = "CENTER",
        ["Anchor"] = "Button",
        ["Opacity"] = 80
    })

    profile.TrackAuras = true
    profile.TrackedAurasHeight = 20
    profile.TrackedAurasSpacing = 2

    profile.MaxUnitsInAxis = 5
    profile.Orientation = "Vertical" --"Vertical", "Horizontal"
    profile.PaddingBetweenUnits = 2 -- Unimplemented

    profile.SortUnitsBy = "ID" -- "ID", "Name", "Class Name"
    profile.SplitRaidIntoGroups = true

    profile.BorderStyle = "Tooltip"-- "Tooltip", "Dialog Box", "Borderless"
end