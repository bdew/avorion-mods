package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include("callable")
include("stringutility")
include("player")
include("faction")
local CaptainUtility = include("captainutility")
local CaptainGenerator = include("captaingenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace HqRecruit
HqRecruit = {}

HqRecruit.generatedCaptains = {}

function HqRecruit.interactionPossible(playerIndex, option)
    local player = Player(playerIndex)
    local ship = player.craft
    if not ship then return false end
    if not ship:hasComponent(ComponentType.Crew) then return false end
    return CheckFactionInteraction(playerIndex, 80000, nil, false)
end

function HqRecruit.initialize()
end

function HqRecruit.initUI()
    local capCount = 0
    local btH = 35
    local btW = 250
    local lblH = 14
    local padding = 10

    local menu = ScriptUI()

    for name, id in pairs(CaptainUtility.ClassType) do
        if id > 0 then
            capCount = capCount + 1
        end
    end

    local res = getResolution()
    local size = vec2(padding * 7 + btW * 2, (capCount + 3) * btH + (capCount + 2) * padding)
    HqRecruit.selectWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    local f1r = Rect(
        padding,
        lblH + padding * 2,
        padding * 3 + btW,
        btH * (capCount + 1) + padding * (capCount + 2) + lblH
    )

    local f2r = Rect(
        padding * 4 + btW,
        lblH + padding * 2,
        padding * 6 + btW * 2,
        btH * (capCount + 1) + padding * (capCount + 2) + lblH
    )

    HqRecruit.selectWindow:createFrame(f1r)
    HqRecruit.selectWindow:createFrame(f2r)

    HqRecruit.selectWindow.caption = "Recruitment" % _t
    HqRecruit.selectWindow.showCloseButton = 1
    HqRecruit.selectWindow.moveable = 1

    local r = Rect(padding, padding, size.x - padding, padding + lblH)
    HqRecruit.selectWindow:createLabel(r, "Our best captains will be happy to work with such a good friend of our faction!" % _t, lblH)

    r = Rect(padding, padding, padding + btW, padding + lblH)
    HqRecruit.selectWindow:createLabel(Rect(f1r.topLeft + r.topLeft, f1r.topLeft + r.bottomRight), "Primary Class" % _t, lblH)
    HqRecruit.selectWindow:createLabel(Rect(f2r.topLeft + r.topLeft, f2r.topLeft + r.bottomRight), "Secondary Class" % _t, lblH)

    for name, id in pairs(CaptainUtility.ClassType) do
        if id > 0 then
            HqRecruit["_onCaptainSelect_p" .. id] = function()
                HqRecruit.selectedPrimary = id
                HqRecruit:updateSelectButtons();
            end
            HqRecruit["_onCaptainSelect_s" .. id] = function()
                HqRecruit.selectedSecondary = id;
                HqRecruit:updateSelectButtons();
            end
            local r = Rect(padding, padding * (id + 1) + btH * (id - 1) + lblH, padding + btW, padding * (id + 1) + btH * id + lblH)
            HqRecruit["_btn_p_" .. id] = HqRecruit.selectWindow:createButton(Rect(f1r.topLeft + r.topLeft, f1r.topLeft + r.bottomRight), name % _t, "_onCaptainSelect_p" .. id)
            HqRecruit["_btn_s_" .. id] = HqRecruit.selectWindow:createButton(Rect(f2r.topLeft + r.topLeft, f2r.topLeft + r.bottomRight), name % _t, "_onCaptainSelect_s" .. id)

            HqRecruit["_frm_p_" .. id] = HqRecruit.selectWindow:createFrame(Rect(f1r.topLeft + r.topLeft, f1r.topLeft + r.bottomRight))
            HqRecruit["_frm_s_" .. id] = HqRecruit.selectWindow:createFrame(Rect(f2r.topLeft + r.topLeft, f2r.topLeft + r.bottomRight))

            HqRecruit["_frm_p_" .. id].visible = false
            HqRecruit["_frm_s_" .. id].visible = false
            HqRecruit["_frm_p_" .. id].backgroundColor = ColorARGB(0.3, 1, 1, 1)
            HqRecruit["_frm_s_" .. id].backgroundColor = ColorARGB(0.3, 1, 1, 1)
        end
    end

    r = Rect(
        padding * 6 + btW * 1,
        btH * (capCount + 1) + padding * (capCount + 3) + lblH,
        padding * 6 + btW * 2,
        btH * (capCount + 2) + padding * (capCount + 3) + lblH
    )

    HqRecruit._btn_complete = HqRecruit.selectWindow:createButton(r, "Continue >" % _t, "onCompleteSelection")

    menu:registerWindow(HqRecruit.selectWindow, "Recruitment" % _t)
end

function HqRecruit:makeCredentialsPanel(idx, captain)
    local size = vec2(320, 400)

    local window = self.captainWindow

    HqRecruit["_recruit_" .. idx] = function()
        HqRecruit.onRecruitCaptainClicked(idx)
    end

    local hsplitBottom = UIHorizontalSplitter(Rect(size.x * (idx - 1), 0, size.x * idx, size.y), 10, 10, 0.5)
    hsplitBottom.bottomSize = 40
    window:createButton(hsplitBottom.bottom, "Recruit" % _t, "_recruit_" .. idx)

    -- icon
    local hsplitTop = UIHorizontalSplitter(hsplitBottom.top, 10, 10, 0.5)
    hsplitTop.topSize = 120
    local captainRect = hsplitTop.top
    captainRect.height = captainRect.height + 30
    captainRect.width = captainRect.height
    local icon = window:createCaptainIcon(captainRect)
    icon:setCaptain(captain)

    -- captain stats
    local classProperties = CaptainUtility.ClassProperties()
    local primary = classProperties[captain.primaryClass]
    local secondary = classProperties[captain.secondaryClass]
    local classDescription = "Tier ${tier} ${captainclass} /* Resolves to something like 'Tier 3 Smuggler' */" % _t
        % { tier = captain.tier, captainclass = primary.displayName }

    local statSplit = UIVerticalLister(hsplitTop.bottom, 0, 0)
    local classLabel = window:createLabel(statSplit:nextRect(15), string.upper(classDescription), 14)
    classLabel:setCenterAligned()
    classLabel.color = primary.primaryColor

    statSplit:nextRect(15) -- empty line

    -- name
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Name:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, captain.name, 12)
    labelRight:setRightAligned()

    statSplit:nextRect(15) -- empty line

    -- primary class
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Primary:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, primary.displayName, 12)
    labelRight:setRightAligned()

    -- secondary class
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Secondary:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, secondary.displayName, 12)
    labelRight:setRightAligned()

    statSplit:nextRect(15) -- empty line

    -- tier
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Tier:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, captain.tier, 12)
    labelRight:setRightAligned()

    -- level
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Level:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, captain.level + 1, 12)
    labelRight:setRightAligned()

    statSplit:nextRect(15) -- empty line

    -- expected salary?
    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Expected Salary:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, string.format("¢%s", createMonetaryString(captain.salary)), 12)
    labelRight:setRightAligned()

    local vsplit = UIVerticalSplitter(statSplit:nextRect(15), 10, 10, 0.5)
    local labelLeft = window:createLabel(vsplit.left, "Recruitment Cost:" % _t, 12)
    labelLeft:setLeftAligned()
    local labelRight = window:createLabel(vsplit.right, string.format("¢%s", createMonetaryString(captain.hiringPrice)), 12)
    labelRight:setRightAligned()
end

function HqRecruit:updateSelectButtons()
    if self.selectedPrimary == self.selectedSecondary then
        self.selectedSecondary = nil
    end

    for name, id in pairs(CaptainUtility.ClassType) do
        if id > 0 then
            self["_btn_s_" .. id].active = self.selectedPrimary ~= id
            self["_frm_p_" .. id].visible = id == self.selectedPrimary
            self["_frm_s_" .. id].visible = id == self.selectedSecondary
        end
    end

    self._btn_complete.active = self.selectedPrimary ~= nil and self.selectedSecondary ~= nil
end

function HqRecruit.onCompleteSelection()
    HqRecruit.selectWindow:hide()
    invokeServerFunction("makeCaptains", HqRecruit.selectedPrimary, HqRecruit.selectedSecondary)
end

function HqRecruit.onShowWindow(optionIndex)
    HqRecruit.selectedPrimary = nil
    HqRecruit.selectedSecondary = nil
    HqRecruit:updateSelectButtons()
end

function HqRecruit.onCloseWindow(optionIndex)
    -- fixme
end

function HqRecruit.makeCaptains(primary, secondary)
    local player = Player(callingPlayer)
    local station = Entity()

    local errors = {}
    errors[EntityType.Station] = "You must be docked to the station to hire crew members." % _t
    if not CheckPlayerDocked(player, station, errors) then
        return
    end

    local generator = CaptainGenerator()

    local captains = {}
    for i = 1, 4 do
        captains[i] = generator:generate(3, nil, primary, secondary)
    end

    HqRecruit.generatedCaptains[callingPlayer] = captains

    invokeClientFunction(player, "showCaptains", captains)
end

function HqRecruit.showCaptains(captains)
    HqRecruit.generatedCaptains = captains
    local dialog = {}
    dialog.text = "Here's 4 of our best captains that would love to work with you!" % _t
    dialog.onEnd = "onShowCaptainsWindow"
    ScriptUI():interactShowDialog(dialog, false)
end

function HqRecruit.onShowCaptainsWindow(captains)
    local res = getResolution()
    local size = vec2(320 * 4, 400)
    HqRecruit.captainWindow = Hud():createWindow(Rect(size))

    HqRecruit.captainWindow.caption = "Potential Recruits" % _t
    HqRecruit.captainWindow.moveable = true
    HqRecruit.captainWindow.showCloseButton = 1
    HqRecruit.captainWindow:center()

    for i, c in ipairs(HqRecruit.generatedCaptains) do
        HqRecruit:makeCredentialsPanel(i, c)
    end

    Hud():addMouseShowingWindow(HqRecruit.captainWindow)
end

function HqRecruit.onRecruitCaptainClicked(idx)
    HqRecruit.captainWindow:hide()
    HqRecruit.captainWindow = nil
    invokeServerFunction("recruitCaptain", idx)
end

function HqRecruit.recruitCaptain(idx)
    local captain = HqRecruit.generatedCaptains[callingPlayer][idx]
    local cost = captain.hiringPrice
    local station = Entity()

    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
    if not buyer then return end

    local canPay, msg, args = buyer:canPay(cost)
    if not canPay then
        player:sendChatMessage("", 1, msg, unpack(args))
        return
    end

    if not ship:hasComponent(ComponentType.Crew) then
        player:sendChatMessage("", 1, "You need to be in a ship that can hold crew.")
        return
    end

    local errors = {}
    errors[EntityType.Station] = "You must be docked to the station to hire crew members." % _t
    if not CheckPlayerDocked(player, station, errors) then
        return
    end

    local crewComponent = CrewComponent(ship)
    if ship:getCaptain() then
        local canHire, msg, args = crewComponent:canAddPassenger(captain)
        if not canHire then
            player:sendChatMessage("", 1, msg, unpack(args))
            return
        end
    end

    buyer:pay("Paid %1% Credits to recruit an expirienced captain." % _t, cost)

    if ship:getCaptain() then
        crewComponent:addPassenger(captain)
    else
        crewComponent:setCaptain(captain)
    end

    player:sendChatMessage(captain.name, 0, string.format("I'm honored to work with you, %s." % _t, player.name))

    HqRecruit.generatedCaptains[callingPlayer] = nil
end

callable(HqRecruit, "makeCaptains")
callable(HqRecruit, "showCaptains")
callable(HqRecruit, "recruitCaptain")
