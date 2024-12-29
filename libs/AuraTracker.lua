-- Detects casts and records the aura times in HMUnit

if not HMUtil.IsSuperWowPresent() then
    return
end

local turtle = HMUtil.IsTurtleWow()
-- Value is duration
local trackedCastedAuras = {
    -- Druid
    ["Rejuvenation"] = 12,
    ["Regrowth"] = 21,
    ["Mark of the Wild"] = 30 * 60,
    ["Gift of the Wild"] = 60 * 60,
    ["Thorns"] = 10 * 60,
    ["Abolish Poison"] = 8,
    ["Innervate"] = 20,
    -- Priest
    ["Power Word: Fortitude"] = 30 * 60,
    ["Divine Spirit"] = 30 * 60,
    ["Shadow Protection"] = 10 * 60,
    ["Prayer of Fortitude"] = 60 * 60,
    ["Prayer of Spirit"] = 60 * 60,
    ["Prayer of Shadow Protection"] = 20 * 60,
    ["Renew"] = 15,
    ["Power Word: Shield"] = 30,
    ["Weakened Soul"] = 15,
    ["Fade"] = 10,
    ["Fear Ward"] = 10 * 60,
    ["Champion's Grace"] = 30 * 60,
    ["Empower Champion"] = 10 * 60,
    ["Spirit of Redemption"] = 10,
    ["Abolish Disease"] = 20,
    ["Inner Fire"] = 10 * 60,
    -- Paladin
    ["Blessing of Protection"] = 10,
    ["Hand of Protection"] = 10,
    ["Divine Shield"] = 12,
    ["Holy Shield"] = 10,
    ["Bulwark of the Righteous"] = 12,
    ["Forbearance"] = 60,
    ["Blessing of Sacrifice"] = 30,
    ["Hand of Sacrifice"] = 30,
    ["Blessing of Wisdom"] = (turtle and 10 or 5) * 60,
    ["Blessing of Might"] = (turtle and 10 or 5) * 60,
    ["Blessing of Salvation"] = (turtle and 10 or 5) * 60,
    ["Blessing of Sanctuary"] = (turtle and 10 or 5) * 60,
    ["Blessing of Kings"] = (turtle and 10 or 5) * 60,
    ["Greater Blessing of Wisdom"] = (turtle and 30 or 15) * 60,
    ["Greater Blessing of Might"] = (turtle and 30 or 15) * 60,
    ["Greater Blessing of Salvation"] = (turtle and 30 or 15) * 60,
    ["Greater Blessing of Sanctuary"] = (turtle and 30 or 15) * 60,
    ["Greater Blessing of Kings"] = (turtle and 30 or 15) * 60,
    -- Shaman
    ["Water Walking"] = 10 * 60,
    -- Mage
    ["Arcane Intellect"] = 30 * 60,
    ["Arcane Brilliance"] = 60 * 60,
    ["Frost Armor"] = 30 * 60,
    ["Ice Armor"] = 30 * 60,
    ["Mage Armor"] = 30 * 60,
    ["Ice Barrier"] = 60,
    ["Mana Shield"] = 60,
    ["Ice Block"] = 10,
    -- Warlock
    ["Soulstone Resurrection"] = 30 * 60,
    ["Unending Breath"] = 10 * 60,
    ["Demon Skin"] = 30 * 60,
    ["Demon Armor"] = 30 * 60,
    -- Rogue
    ["Evasion"] = 15,
    -- Hunter
    ["Deterrence"] = 10,
    ["Rapid Fire"] = 15,
    -- Warrior
    ["Battle Shout"] = 2 * 60,
    ["Shield Wall"] = 10, -- 12 with talent
    -- Racial
    ["Quel'dorei Meditation"] = 5,
    ["Grace of the Sunwell"] = 10,
    -- Generic
    ["First Aid"] = 8,
    ["Recently Bandaged"] = 60,
}

-- Auras to start the timer for even though they weren't directly casted
local additionalAuras = {
    ["Divine Protection"] = {"Forbearance"},
    ["Divine Shield"] = {"Forbearance"},
    ["Blessing of Protection"] = {"Forbearance"},
    ["Hand of Protection"] = {"Forbearance"},
    ["First Aid"] = {"Recently Bandaged"},
    ["Power Word: Shield"] = {"Weakened Soul"}
}

-- Value is range
local aoeAuras = {
    ["Prayer of Fortitude"] = 100, 
    ["Prayer of Spirit"] = 100, 
    ["Prayer of Shadow Protection"] = 100, 
    ["Arcane Brilliance"] = 100, 
    ["Gift of the Wild"] = 100, 
    ["Battle Shout"] = 20
}

-- Paladins always get their own special stuff..
-- Their buffs are aoe but apply to the whole raid for a specific class
local aoeClassAuras = HMUtil.ToSet({
    "Greater Blessing of Wisdom", "Greater Blessing of Might", "Greater Blssing of Salvation", 
    "Greater Blessing of Sanctuary", "Greater Blessing of Kings"
})

local function applyTimedAura(spellName, units)
    for _, unit in ipairs(units) do
        HMUnit.Get(unit).AuraTimes[spellName] = {["startTime"] = GetTime(), ["duration"] = trackedCastedAuras[spellName]}
        for ui in HealersMate.UnitFrames(unit) do
            ui:UpdateAuras()
        end
    end
end

local castEventFrame = CreateFrame("Frame")
castEventFrame:RegisterEvent("UNIT_CASTEVENT")
castEventFrame:SetScript("OnEvent", function()
    local caster, target, event, spellID, duration = arg1, arg2, arg3, arg4, arg5

    if event == "CAST" or event == "CHANNEL" then
        local spellName = SpellInfo(spellID)
        if trackedCastedAuras[spellName] then
            if target == "" then
                target = caster
            end
            local units = HMGuidRoster.GetUnits(target)
            if not units then
                return
            end
            if aoeAuras[spellName] then
                local targets = HMUtil.GetSurroundingPartyMembers(target, aoeAuras[spellName])
                for _, unit in ipairs(targets) do
                    local units = HMGuidRoster.GetAllUnits(unit)
                    applyTimedAura(spellName, units)
                end
            elseif aoeClassAuras[spellName] then
                local class = HMUtil.GetClass(target)
                local targets = HMUtil.GetSurroundingRaidMembers(target, 100)
                for _, unit in ipairs(targets) do
                    if HMUtil.GetClass(unit) == class then
                        local units = HMGuidRoster.GetAllUnits(unit)
                        applyTimedAura(spellName, units)
                    end
                end
            else
                applyTimedAura(spellName, units)
            end

            if additionalAuras[spellName] then
                for _, aura in ipairs(additionalAuras[spellName]) do
                    applyTimedAura(aura, units)
                end
            end
        end
    end
end)