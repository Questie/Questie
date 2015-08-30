-- Aero's FrameFramework --

PF_BACK_TEXTURE = "Icons\\temporaryborders";

function PF_hideAll(frame)
	frame:Hide();
	if not (frame.parent == nil) then
		PF_hideAll(frame.parent);
	end
end

function PF_closesubmenus(frame)
	for k,v in pairs(frame.submenus) do 
		v:Hide();
		PF_closesubmenus(v);
	end
end

function createPrettyMenu(contents, x, y)
	DEFAULT_CHAT_FRAME:AddMessage("Creating PrettyMenu at " .. x .. ", " .. y);
	local frame = CreateFrame("Frame", "PrettyMenu" .. x .. y, UIParent)
	frame.over  = false;
	
	local submenus = {};
	frame.submenus = submenus;
	--frame:SetScript("OnEnter", function(a) DEFAULT_CHAT_FRAME:AddMessage("ENTER " .. x);frame.over = true; end);
	--frame:SetScript("OnLeave", function(a) DEFAULT_CHAT_FRAME:AddMessage("EXIT " .. x);frame.over = false; end);
	
	frame.buttons = {};
	local count = table.getn(contents); -- this is fucked
	local realcount = 0;
	frame:SetWidth(160); 
	for k,v in pairs(contents) do
		local buttonframe = CreateFrame("Button",nil,frame)
		buttonframe:SetWidth(frame:GetWidth());
		buttonframe:SetHeight(16);
		--buttonframe:SetPoint("TOPLEFT",8,-28-(i-1)*buttonHeight)
		buttonframe:SetPoint("TOPLEFT", frame, 0, -((realcount*14)+7))
		buttonframe:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
		local sk = v['click'];
		if not (sk == nil) then
			buttonframe:SetScript("OnClick",function(a) sk(); PF_hideAll(frame) end);
		end
		
		local submenu = v['submenu'];
		if not (submenu == nil) then
			local add = 140;
			if x+add > GetScreenWidth() / 2 then
				add = -add;
			end
			local sub = createPrettyMenu(submenu, x + add, y);
			sub.parent = frame;
			sub:Hide();
			table.insert(submenus, sub);
			buttonframe:SetScript("OnEnter", function(a) sub:Show(); end);
			--buttonframe:SetScript("OnLeave", function(a, b) DEFAULT_CHAT_FRAME:AddMessage(a);if not sub.over then sub:Hide() end end);
		else
			buttonframe:SetScript("OnEnter", function(a) PF_closesubmenus(frame); end);
			--buttonframe:SetScript("OnLeave", function(a, b) frame.over  = false; end);
		end
		
		local text = buttonframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		text:SetPoint("CENTER", buttonframe, 0, 0)
		text:SetText("|cffffffff" .. k .. "|r")
		
		buttonframe.text = text;
		
		local buttondata = {['frame']=buttonframe,['text']=k,['func']=v['click']};
		
		table.insert(frame.buttons, buttondata);
		
		realcount = realcount + 1;
	end
	count = realcount;
	-- The code below makes the frame visible, and is not necessary to enable dragging.
	frame:SetPoint("BOTTOMLEFT", x, y); 
	frame:SetHeight(count * 14 + 15);
	local tex = frame:CreateTexture("ARTWORK");
	tex:SetAllPoints();
	tex:SetTexture(0,0,0);
	tex:SetAlpha(0.4)
	--tex:SetTexture("Interface\\AddOns\\Questie\\" .. PF_BACK_TEXTURE); 
	
	--for k,v in pairs(contents) do
	--	local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--	text:SetPoint("CENTER", frame, 0, 0)
	--	text:SetText(k)
	--end
	
	--frame:Show();
	
	--DEFAULT_CHAT_FRAME:AddMessage("Created PrettyMenu with entry count: " .. count .. " realcount: " .. realcount);
	
	return frame;
	--tex:SetTexture(1.0, 0.5, 0);

end


function PF_TEST()
	local menu = createPrettyMenu({
		["Test"]=
			{
				['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("TestClicked");end
			},
		["< SubMenuTest"]=
			{
				['click'] = nil,
				['submenu'] = {
					['SubTest1'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest1");end},
					['SubTest2'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest2");end},
					['SubTest3'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest3");end},
					['SubTest4'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest4");end},
					['SubTest5'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest5");end},
					['SubTest6'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest6");end},
					['< SubSubMenuTest'] = {
						['click'] = nil,
						['submenu'] = {
							['SubSubTest1'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubSubTest1");end},
							['SubSubTest2'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubSubTest2");end},
							['SubSubTest3'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubSubTest3");end},
							['< even more'] = {['click'] = nil,
							['submenu'] = {
								['SubTest1'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest1");end},
								['SubTest2'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest2");end},
								['SubTest3'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest3");end},
								['SubTest4'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest4");end},
								['SubTest5'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest5");end},
								['< even more!'] = {['click'] = nil,
								['submenu'] = {
									['SubTest1'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest1");end},
									['SubTest2'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest2");end},
									['SubTest3'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest3");end},
									['< even more!!'] = {['click'] = nil,
									['submenu'] = {
										['SubTest1'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest1");end},
										['SubTest2'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest2");end},
										['SubTest3'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest3");end},
										['SubTest4'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest4");end},
										['SubTest5'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest5");end},
										['SubTest6'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest6");end}
									}
									},
									['SubTest5'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest5");end},
									['SubTest6'] = {['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("SubTest6");end}
								}
								}
							}
							}
						}
					}
				}
				--['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("TestClicked2");end
			},
		["Test2"]=
			{
				['click'] = function() DEFAULT_CHAT_FRAME:AddMessage("TestClicked2");end
			}
	},0,0)
	menu:Show();
end
