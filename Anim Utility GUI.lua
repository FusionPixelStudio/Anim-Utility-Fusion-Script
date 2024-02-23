local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

local width, height = 370,450
local hPos, vPos = 880,350

local node = comp.ActiveTool
local flow = comp.CurrentFrame.FlowView

local msgWnd = disp:AddWindow(
	{
		ID = "MsgWindow",
		WindowTitle = "Anim Utility | Message",
		Geometry = { hPos,vPos,width,height - 350 },
        MinimumSize = {200, 50},
        ui:VGroup{
            ID = "root",
            ui:VGroup{
                ui:Label{ID = 'msg', Text = '', Weight = 0.25, WordWrap = true, Alignment = { AlignHCenter = true, AlignTop = true }, StyleSheet = [[QLabel { color: rgb(255, 255, 255); font-weight: bold; }]]},
                ui:Button{ID = 'OK', Text = 'OK', Weight = 0.05},
            }
        }
    }
)
local msgWnditm = msgWnd:GetItems()

local mainWnd = disp:AddWindow(
	{
		ID = "MainWindow",
		WindowTitle = "Anim Utility | Selector",
		Geometry = { hPos,vPos,width,height },
        MinimumSize = {300, 450},

		ui:VGroup{
            ID = "root",
            ui:HGroup{
				Weight = 0.02,
                ui:Label{ID = 'ControlsLabel', Text = 'Node Controls (Click a Control to Select)', Weight = 0.02},
				ui:Button{ID = 'Reload', Text = 'Reload', Weight = 0.005},
			},
			ui:VGroup{
				ui:LineEdit{ID = 'SearchBar', PlaceholderText = 'Enter Control ID to Search',Weight = 0.01},
                ui:Tree{ID = 'NodeControls', SortingEnabled = true, Events = { ItemClicked = true }, Weight = 0.25},
                ui:LineEdit{ ID = 'UniqueName', PlaceholderText = 'Unique Name for Modifiers', Weight = 0.03},
                ui:Button{ID = 'Paste', Text = 'Paste Anim Utility', Weight = 0.02},
            },
        }
    }
)
local mainWnditm = mainWnd:GetItems()

function mainWnd.On.MainWindow.Close(ev)
	disp:ExitLoop()
end

function msgWnd.On.MsgWindow.Close(ev)
	disp:ExitLoop()
end

function msgWnd.On.OK.Clicked(ev)
	disp:ExitLoop()
end

local function showMessage(str)
	msgWnditm.msg.Text = str
	msgWnd:Show()
	disp:RunLoop()
	msgWnd:Hide()
end

local function fillTree()
	local tool = comp.ActiveTool
    local x = tool:GetInputList()
    for _, inp in pairs(x) do
		local control_type = inp:GetAttrs().INPS_DataType
        local control = inp:GetAttrs().INPS_ID 
		local controlName = inp:GetAttrs().INPS_Name
		if control_type == 'Number' then
			--print(input_type)
        local it = mainWnditm.NodeControls:NewItem()
            it.Text[0] = control
			it.Text[1] = controlName
            mainWnditm.NodeControls:AddTopLevelItem(it)
		end
    end
end

local function animUtility(uniqueName)
    local s = [[
        {
            Tools = ordered() { ]]
            .. uniqueName .. [[_MASTERANIM = Calculation {
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				}
			},
			Inputs = {
				CONNECT = Input {
					SourceOp = "]] .. uniqueName .. [[_USER",
					Source = "Value",
				}
			},
			UserControls = ordered() {
				HiddenControls = {
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 3,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "Hidden Controls",
					INP_Passive = true,
					ICS_ControlPage = "Calc",
					IC_Visible = false,
				},
				FirstOperand = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "First Operand"
				},
				Operator = {
					{ CCS_AddString = "Add" },
					{ CCS_AddString = "Subtract (First - Second)" },
					{ CCS_AddString = "Multiply" },
					{ CCS_AddString = "Divide   (First / Second)" },
					{ CCS_AddString = "Divide   (Second / First)" },
					{ CCS_AddString = "Subtract (Second - First)" },
					{ CCS_AddString = "Minimum" },
					{ CCS_AddString = "Maximum" },
					{ CCS_AddString = "Average" },
					{ CCS_AddString = "First Only" },
					{ CCS_AddString = "Second Only" },
					{ CCS_AddString = "Add Random" },
					{ CCS_AddString = "Multiply Random" },
					{ CCS_AddString = "Modulo (First % Second)" },
					{ CCS_AddString = "Modulo (Second % First)" },
					{ CCS_AddString = "Difference" },
					{ CCS_AddString = "Power (First ^ Second)" },
					{ CCS_AddString = "Power (Second ^ First)" },
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ComboControl",
					CC_LabelPosition = "Horizontal",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "Operator"
				},
				SecondOperand = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "Second Operand"
				},
				CONNECT = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CONNECT",
				}
			}
		},]]
        .. uniqueName .. [[_ANIMINCURVES = LUTLookup {
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				},
			},
			Inputs = {
				Curve = Input { Value = FuID { "Custom" }, },
				EaseIn = Input { Value = FuID { "Quint" }, },
				EaseOut = Input { Value = FuID { "Sine" }, },
				Lookup = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMINCURVESLookup",
					Source = "Value",
				},
				Source = Input { Value = FuID { "Duration" }, },
				Scale = Input { Expression = "iif(]] .. uniqueName .. [[_USER.IN == 1, 1, 0)", },
				Offset = Input { Expression = "iif(]] .. uniqueName .. [[_USER.IN == 1, 0, 1)", },
				TimeScale = Input {
					Value = 12.4166666666667,
					Expression = "(comp.RenderEnd-comp.RenderStart)/]] .. uniqueName .. [[_USER.ANIMLENGTHIN",
				},
				TimeOffset = Input { Expression = "]] .. uniqueName .. [[_USER.ANIMOFFSETIN/(comp.RenderEnd-comp.RenderStart)", }
			},
			UserControls = ordered() {
				HiddenControls = {
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 12,
					INP_External = false,
					LINKID_DataType = "Number",
					IC_Visible = false,
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "Hidden Controls",
				},
				CurveShape = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 8,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_MinAllowed = 0,
					INP_MinScale = 0,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_Passive = true,
					LBLC_NestLevel = 0,
					ICS_ControlPage = "Controls",
					LINKS_Name = "Curve Shape"
				},
				Source = {
					{ CCS_AddString = "Duration" },
					{ CCS_AddString = "Transition" },
					{ CCS_AddString = "Custom" },
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CC_LabelPosition = "Horizontal",
					INPID_InputControl = "ComboControl",
					LINKS_Name = "Source",
				},
				Mirror = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					ICD_Width = 0.5,
					LINKS_Name = "Mirror"
				},
				Invert = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					ICD_Width = 0.5,
					LINKS_Name = "Invert"
				},
				Scaling = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 4,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_MinAllowed = 0,
					INP_MinScale = 0,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_Passive = true,
					LBLC_NestLevel = 0,
					ICS_ControlPage = "Controls",
					LINKS_Name = "Scaling"
				},
				Scale = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 2,
					INP_Default = 1,
					INP_MinScale = -2,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Center = 1,
					LINKS_Name = "Scale"
				},
				Offset = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 5,
					INP_Default = 0,
					INP_MinScale = -5,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Offset"
				},
				ClipLow = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					ICD_Width = 0.5,
					LINKS_Name = "Clip Low"
				},
				ClipHigh = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					ICD_Width = 0.5,
					LINKS_Name = "Clip High"
				},
				Timing = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 2,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_MinAllowed = 0,
					INP_MinScale = 0,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_Passive = true,
					LBLC_NestLevel = 0,
					ICS_ControlPage = "Controls",
					LINKS_Name = "Timing"
				},
				TimeScale = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Time Scale"
				},
				TimeOffset = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_Default = 0,
					INP_MinScale = -1,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Time Offset"
				}
			}
		},]]
        .. uniqueName .. [[_ANIMINCURVESLookup = LUTBezier {
			KeyColorSplines = {
				[0] = {
					[0] = { 0, RH = { 0.333333333333333, 0 }, Flags = { Linear = true } },
					[1] = { 1, LH = { 0.666666666666667, 1 } }
				}
			},
			SplineColor = { Red = 255, Green = 255, Blue = 255 },
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				}
			},
		},]]
        .. uniqueName .. [[_ANIMOUTCURVES = LUTLookup {
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				},
			},
			Inputs = {
				Curve = Input { Value = FuID { "Custom" }, },
				EaseIn = Input { Value = FuID { "Sine" }, },
				EaseOut = Input { Value = FuID { "Quint" }, },
				Lookup = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMOUTCURVESLookup",
					Source = "Value",
				},
				Source = Input { Value = FuID { "Duration" }, },
				Scale = Input {
					Value = -1,
					Expression = "iif(]] .. uniqueName .. [[_USER.OUT == 1, -1, 0)",
				},
				TimeScale = Input {
					Value = 12.4166666666667,
					Expression = "(comp.RenderEnd-comp.RenderStart)/]] .. uniqueName .. [[_USER.ANIMLENGTHOUT",
				},
				TimeOffset = Input {
					Value = 0.919463087248322,
					Expression = "iif(]] .. uniqueName .. [[_USER.OFFSETSWITCH == 1, (]] .. uniqueName .. [[_USER.ANIMOFFSETOUT/(comp.RenderEnd-comp.RenderStart)),1-((]] .. uniqueName .. [[_USER.ANIMLENGTHOUT+]] .. uniqueName .. [[_USER.ANIMOFFSETOUT)/(comp.RenderEnd-comp.RenderStart)))",
				}
			},
			UserControls = ordered() {
				HiddenControls = {
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 12,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "Hidden Controls",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					IC_Visible = false,
				},
				CurveShape = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 8,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_External = false,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LBLC_NestLevel = 0,
					INP_Passive = true,
					LINKS_Name = "Curve Shape"
				},
				Source = {
					{ CCS_AddString = "Duration" },
					{ CCS_AddString = "Transition" },
					{ CCS_AddString = "Custom" },
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CC_LabelPosition = "Horizontal",
					INPID_InputControl = "ComboControl",
					LINKS_Name = "Source",
				},
				Mirror = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					CBC_TriState = false,
					LINKS_Name = "Mirror"
				},
				Invert = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					CBC_TriState = false,
					LINKS_Name = "Invert"
				},
				Scaling = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 4,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_External = false,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LBLC_NestLevel = 0,
					INP_Passive = true,
					LINKS_Name = "Scaling"
				},
				Scale = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 2,
					INP_Default = 1,
					INP_MinScale = -2,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Center = 1,
					LINKS_Name = "Scale"
				},
				Offset = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 5,
					INP_Default = 0,
					INP_MinScale = -5,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Offset"
				},
				ClipLow = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					CBC_TriState = false,
					LINKS_Name = "Clip Low"
				},
				ClipHigh = {
					INP_MaxAllowed = 1,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					CBC_TriState = false,
					LINKS_Name = "Clip High"
				},
				Timing = {
					INP_MaxAllowed = 1,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 2,
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_External = false,
					INP_MinScale = 0,
					INP_MinAllowed = 0,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LBLC_NestLevel = 0,
					INP_Passive = true,
					LINKS_Name = "Timing"
				},
				TimeScale = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_Default = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Time Scale"
				},
				TimeOffset = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_Default = 0,
					INP_MinScale = -1,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Time Offset"
				}
			}
		},]]
        .. uniqueName .. [[_ANIMOUTCURVESLookup = LUTBezier {
			KeyColorSplines = {
				[0] = {
					[0] = { 0, RH = { 0.333333333333333, 0 }, Flags = { Linear = true } },
					[1] = { 1, LH = { 0.666666666666667, 1 } }
				}
			},
			SplineColor = { Red = 255, Green = 255, Blue = 255 },
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				}
			},
		},]]
        .. uniqueName .. [[_USER = PublishNumber {
			CtrlWZoom = false,
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				},
			},
			Inputs = {
				AnimIn = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMINCURVES",
					Source = "Value",
				},
				AnimOut = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMOUTCURVES",
					Source = "Value",
				},
				MasterAnim = Input {
					SourceOp = "]] .. uniqueName .. [[_CALCMAIN",
					Source = "Result",
				},
				From0 = Input { Expression = "MasterAnim*INPUTAMOUNT", },
				FromINPUT = Input { Expression = "-(MasterAnim-1)*INPUTAMOUNT", },
				FromCUSTOM = Input { Expression = "CUSTOMINPUTSTART + (MasterAnim*(CUSTOMINPUTEND-CUSTOMINPUTSTART))", },
				Value = Input { Expression = "From0", },
				IN = Input { Value = 1, },
				OUT = Input { Value = 1, },
				INPUTOPTIONS = Input { Value = 1, },
				ANIMLENGTHIN = Input { Value = 24, },
				ANIMLENGTHOUT = Input { Value = 24, },
				CURRENTFRAME = Input { Expression = "(comp.RenderStart-comp.RenderStart)+time", },
				OFFSETINSTART = Input {
					Value = -24,
					Expression = "(comp.RenderStart-comp.RenderStart)+time-ANIMLENGTHIN",
				},
				OFFSETOUTSTART = Input {
					Value = 274,
					Expression = "comp.RenderEnd-time-ANIMLENGTHOUT",
				},
				OTHERTHINGS = Input { Value = 1, },
				DETAILS = Input { Value = "Based on MiniAnimator by MrAlexTech\nBased Anim Logic From Patrick Stirling's Subtitles Pro\n------------------\nAnim Utility by AsherRoland", },
			},
			UserControls = ordered() {
				HiddenControls = {
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 7,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_Passive = true,
					IC_Visible = false,
					LINKS_Name = "Hidden Controls",
				},
				AnimIn = {
					INPID_InputControl = "SliderControl",
					INP_Integer = false,
					LINKID_DataType = "Number",
					LINKS_Name = "AnimIn",
				},
				AnimOut = {
					INPID_InputControl = "SliderControl",
					INP_Integer = false,
					LINKID_DataType = "Number",
					LINKS_Name = "AnimOut",
				},
				MasterAnim = {
					INPID_InputControl = "SliderControl",
					INP_Integer = false,
					LINKID_DataType = "Number",
					LINKS_Name = "MasterAnim",
				},
				From0 = {
					INPID_InputControl = "ScrewControl",
					INP_Integer = false,
					LINKID_DataType = "Number",
					LINKS_Name = "From 0",
				},
				FromINPUT = {
					INPID_InputControl = "ScrewControl",
					INP_Integer = false,
					LINKID_DataType = "Number",
					LINKS_Name = "From INPUT",
				},
				FromCUSTOM = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					INPID_InputControl = "ScrewControl",
					INP_MinScale = 0,
					INP_MaxScale = 1,
					LINKS_Name = "From CUSTOM",
				},
				Value = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					INPID_InputControl = "ScrewControl",
					INP_MinScale = 0,
					INP_MaxScale = 1,
					LINKS_Name = "Value",
				},
				TUTORIAL = {
					ICD_Width = 1,
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "ButtonControl",
					LINKS_Name = "TUTORIAL",
				},
				Sep5 = {
					INP_External = false,
					INPID_InputControl = "SeparatorControl",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "",
				},
				CUSTOMCONTROLS = {
					ICS_ControlPage = "Controls",
					INP_Integer = false,
					LBLC_DropDownButton = false,
					LINKID_DataType = "Number",
					INP_External = false,
					INP_Passive = true,
					INPID_InputControl = "LabelControl",
					LINKS_Name = "<p style=\"color:yellow;\">CUSTOM CONTROLS</p>",
				},
				IN = {
					ICD_Width = 0.5,
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					INPID_InputControl = "CheckboxControl",
					LINKS_Name = "IN",
				},
				OUT = {
					ICD_Width = 0.5,
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					INPID_InputControl = "CheckboxControl",
					LINKS_Name = "OUT",
				},
				INPUTOPTIONS = {
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 10,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "0 TO INPUT OPTIONS",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					IC_Visible = false,
				},
				Sep2 = {
					INP_External = false,
					INPID_InputControl = "SeparatorControl",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "",
				},
				INPUTAMOUNT = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "INPUT AMOUNT",
				},
				INVERT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.Value:SetExpression(\"FromINPUT\")\ntool.FromINPUT:SetExpression(\"iif(SPLITINVERTINPUT==0, -(MasterAnim-1)*INPUTAMOUNT, iif(time >ANIMLENGTHIN+ANIMOFFSETIN, -(MasterAnim-1)*INVERTINPUTOUT,-(MasterAnim-1)*INVERTINPUTIN))\")\ntool:SetInput('INVERTEDOPTIONS', 1)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "INVERT 0&INPUT"
				},
				INVERTEDOPTIONS = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 6,
					INP_MaxScale = 1,
					Expression = "iif(SPLITINVERTINPUT==1,1,0)",
					LINKS_Name = "SPLIT INVERTED OPTIONS",
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INP_Passive = true,
					INP_External = false,
					IC_Visible = false
				},
				REVERT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.Value:SetExpression(\"From0\")\ntool.FromINPUT:SetExpression(\"-(MasterAnim-1)*INPUTAMOUNT\")\ntool:SetInput('INVERTEDOPTIONS', 0)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "REVERT"
				},
				SPLITINVERTINPUT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					CBC_TriState = false,
					LINKS_Name = "SPLIT INVERT INPUT"
				},
				["INVERT_/"] = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromINPUT:SetExpression(\"iif(SPLITINVERTINPUT==0, -(MasterAnim-1)*INPUTAMOUNT, iif(time >ANIMLENGTHIN+ANIMOFFSETIN, -(MasterAnim-1)*INVERTINPUTIN,-(MasterAnim-1)*INVERTINPUTOUT))\")",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.75,
					LINKS_Name = "INVERT IN/OUT"
				},
				REVERTINPUTS = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromINPUT:SetExpression(\"iif(SPLITINVERTINPUT==0, -(MasterAnim-1)*INPUTAMOUNT, iif(time >ANIMLENGTHIN+ANIMOFFSETIN, -(MasterAnim-1)*INVERTINPUTOUT,-(MasterAnim-1)*INVERTINPUTIN))\")",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.25,
					LINKS_Name = "REVERT"
				},
				INVERTINPUTIN = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "INVERT INPUT IN",
				},
				INVERTINPUTOUT = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "INVERT INPUT OUT",
				},
				Sep1 = {
					INP_External = false,
					INPID_InputControl = "SeparatorControl",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "",
				},
				ENABLECUSTOM = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.Value:SetExpression(\"FromCUSTOM\")\ntool:SetInput('FULLYCUSTOMOPTIONS', 1)\ntool:SetInput('INPUTOPTIONS', 0)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "ENABLE CUSTOM"
				},
				FULLYCUSTOMOPTIONS = {
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 12,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "FULLY CUSTOM OPTIONS",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					IC_Visible = false,
				},
				RESETTODEFUALT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.Value:SetExpression(\"From0\")\ntool:SetInput('FULLYCUSTOMOPTIONS', 0)\ntool:SetInput('INPUTOPTIONS', 1)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "RESET"
				},
				CUSTOMINPUTSTART = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CUSTOM INPUT START",
				},
				CUSTOMINPUTEND = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CUSTOM INPUT END",
				},
				INVERTCUSTOMs = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromCUSTOM:SetExpression(\"iif(SPLITCUSTOMINPUTS == 0, CUSTOMINPUTEND + (MasterAnim*(CUSTOMINPUTSTART-CUSTOMINPUTEND)), iif(time>ANIMLENGTHIN+ANIMOFFSETIN, CUSTOMINPUTENDOUT + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTENDOUT)), CUSTOMINPUTSTARTIN + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTSTARTIN))))\")\ntool:SetInput('SPLITCUSTOMOPTIONS', 1)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "INVERT START&END"
				},
				SPLITCUSTOMOPTIONS = {
					INP_Integer = true,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 7,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "SPLIT CUSTOM OPTIONS",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					IC_Visible = false,
				},
				REVERTCUSTOMs = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromCUSTOM:SetExpression(\"CUSTOMINPUTSTART + (MasterAnim*(CUSTOMINPUTEND-CUSTOMINPUTSTART))\")\ntool:SetInput('SPLITCUSTOMOPTIONS', 0)",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 1,
					LINKS_Name = "REVERT"
				},
				SPLITCUSTOMINPUTS = {
					CBC_TriState = false,
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "CheckboxControl",
					LINKS_Name = "SPLIT CUSTOM INPUTS",
				},
				INVERTIN_OUT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromCUSTOM:SetExpression(\"iif(SPLITCUSTOMINPUTS == 0, CUSTOMINPUTEND + (MasterAnim*(CUSTOMINPUTSTART-CUSTOMINPUTEND)), iif(time>ANIMLENGTHIN+ANIMOFFSETIN, CUSTOMINPUTSTARTIN + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTSTARTIN)), CUSTOMINPUTENDOUT + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTENDOUT))))\")",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.75,
					LINKS_Name = "INVERT IN/OUT"
				},
				REVERTIN_OUT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.FromCUSTOM:SetExpression(\"iif(SPLITCUSTOMINPUTS == 0, CUSTOMINPUTEND + (MasterAnim*(CUSTOMINPUTSTART-CUSTOMINPUTEND)), iif(time>ANIMLENGTHIN+ANIMOFFSETIN, CUSTOMINPUTENDOUT + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTENDOUT)), CUSTOMINPUTSTARTIN + (MasterAnim*(CUSTOMINPUTMID-CUSTOMINPUTSTARTIN))))\")",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.25,
					LINKS_Name = "REVERT"
				},
				CUSTOMINPUTSTARTIN = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CUSTOM INPUT START IN",
				},
				CUSTOMINPUTMID = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CUSTOM INPUT MID",
				},
				CUSTOMINPUTENDOUT = {
					INP_Integer = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CUSTOM INPUT END OUT",
				},
				Sep3 = {
					INP_External = false,
					INPID_InputControl = "SeparatorControl",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "",
				},
				ANIMATIONOPTIONS = {
					ICS_ControlPage = "Controls",
					INP_Integer = false,
					LBLC_DropDownButton = false,
					LINKID_DataType = "Number",
					INP_External = false,
					INP_Passive = true,
					INPID_InputControl = "LabelControl",
					LINKS_Name = "<p style=\"color:yellow;\">TIMING OPTIONS</p>",
				},
				ANIMLENGTHIN = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "SliderControl",
					INP_MaxScale = 100,
					INP_MinScale = 1,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "LENGTH IN"
				},
				ANIMLENGTHOUT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "SliderControl",
					INP_MaxScale = 100,
					INP_MinScale = 1,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "LENGTH OUT"
				},
				ANIMOFFSETIN = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "SliderControl",
					INP_MaxScale = 100,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "START FRAME IN"
				},
				ANIMOFFSETOUT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "SliderControl",
					INP_MaxScale = 100,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "END FRAME OUT"
				},
				CHANGEOFFSETOUTMETHOD = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.OFFSETOUTSTART:SetExpression(\"(comp.RenderStart-comp.RenderStart)+time-ANIMLENGTHOUT\")\ntool:SetInput('OFFSETSWITCH', 1)\ntool.ANIMOFFSETOUT:SetAttrs({INPS_Name = \"START FRAME OUT\"})\ntool.OFFSETOUTSTART:SetAttrs({INPS_Name = \"OUT START FRAME ON END\"})",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					LINKS_Name = "SWAP FRAMEOUT MATH"
				},
				REVERTOFFSET = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "tool.OFFSETOUTSTART:SetExpression(\"comp.RenderEnd-time-ANIMLENGTHOUT\")\ntool:SetInput('OFFSETSWITCH', 0)\ntool.ANIMOFFSETOUT:SetAttrs({INPS_Name = \"END FRAME OUT\"})\ntool.OFFSETOUTSTART:SetAttrs({INPS_Name = \"OUT END FRAME ON START\"})",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.25,
					LINKS_Name = "REVERT"
				},
				OFFSETSWITCH = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "CheckboxControl",
					INP_MaxScale = 1,
					CBC_TriState = false,
					ICD_Width = 0.1,
					INP_MinScale = 0,
					INP_External = false,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INP_Passive = true,
					INP_MinAllowed = -1000000,
					LINKS_Name = ""
				},
				CURRENTFRAME = {
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "CURRENT FRAME",
				},
				OFFSETINSTART = {
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "IN START FRAME ON END",
				},
				OFFSETOUTSTART = {
					INP_Integer = true,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					INPID_InputControl = "SliderControl",
					LINKS_Name = "OUT END FRAME ON START",
				},
				OTHERTHINGS = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 8,
					INP_MaxScale = 1,
					LBLC_MultiLine = true,
					INP_MinScale = 0,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_MinAllowed = -1000000,
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					LINKS_Name = "<p style=\"font-size:15px; color:gold; font-style:extrabold; text-align:left;\">OTHER THINGS</p>"
				},
				MyLinks = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "					os.execute('open \\\"\\\" \\\"https://linktr.ee/asherroland\\\"')\n					os.execute('start \\\"\\\" \\\"https://linktr.ee/asherroland\\\"')					",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "My Links"
				},
				MrAlexTech = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "					os.execute('open \\\"\\\" \\\"https://www.youtube.com/c/mralextech\\\"')\n					os.execute('start \\\"\\\" \\\"https://www.youtube.com/c/mralextech\\\"')					",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					LINKS_Name = "MrAlexTech"
				},
				PatrickSterling = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "					os.execute('open \\\"\\\" \\\"https://www.youtube.com/@PatrickStirling\\\"')\n					os.execute('start \\\"\\\" \\\"https://www.youtube.com/@PatrickStirling\\\"')					",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					ICD_Width = 0.5,
					LINKS_Name = "Patrick Stirling"
				},
				DETAILS = {
					TEC_ReadOnly = true,
					INPID_InputControl = "TextEditControl",
					TEC_Lines = 6,
					INP_External = false,
					LINKID_DataType = "Text",
					LINKS_Name = "About",
					INP_Passive = true,
					ICS_ControlPage = "Controls",
					TEC_Wrap = true,
				},
				SpecialThanks = {
					INP_Integer = false,
					LBLC_DropDownButton = false,
					ICS_ControlPage = "Controls",
					LBLC_MultiLine = true,
					INP_External = false,
					LINKID_DataType = "Number",
					INP_Passive = true,
					INPID_InputControl = "LabelControl",
					LINKS_Name = "<p style=\"font-size:13px; color:gold; font-style:extrabold;\">Special Thanks</p>",
				},
				X_Session = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "					os.execute('open \\\"\\\" \\\"https://www.youtube.com/@XSession\\\"')\n					os.execute('start \\\"\\\" \\\"https://www.youtube.com/@XSession\\\"')					",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "X-Session"
				},
				DavinciResolveDiscord = {
					INP_MaxAllowed = 1000000,
					INP_Integer = true,
					INPID_InputControl = "ButtonControl",
					BTNCS_Execute = "					os.execute('open \\\"\\\" \\\"https://discord.gg/davinci-resolve-community-714620142096482314\\\"')\n					os.execute('start \\\"\\\" \\\"https://discord.gg/davinci-resolve-community-714620142096482314\\\"')					",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Controls",
					LINKS_Name = "Davinci Resolve Discord"
				}
			}
		},]]
        .. uniqueName .. [[_CALCMAIN = Calculation {
			NameSet = true,
			CustomData = {
				Path = {
					Map = {
						["Setting:"] = "Macros:\\Asher Roland\\"
					}
				}
			},
			Inputs = {
				FirstOperand = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMINCURVES",
					Source = "Value",
				},
				SecondOperand = Input {
					SourceOp = "]] .. uniqueName .. [[_ANIMOUTCURVES",
					Source = "Value",
				}
			},
			UserControls = ordered() {
				HiddenControls = {
					INP_Integer = false,
					LBLC_DropDownButton = true,
					INPID_InputControl = "LabelControl",
					LBLC_NumInputs = 4,
					INP_External = false,
					LINKID_DataType = "Number",
					LINKS_Name = "Hidden Controls",
					INP_Passive = true,
					ICS_ControlPage = "Calc",
					IC_Visible = false,
				},
				CONNECT = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "SliderControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "CONNECT"
				},
				FirstOperand = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "First Operand"
				},
				Operator = {
					{ CCS_AddString = "Add" },
					{ CCS_AddString = "Subtract (First - Second)" },
					{ CCS_AddString = "Multiply" },
					{ CCS_AddString = "Divide   (First / Second)" },
					{ CCS_AddString = "Divide   (Second / First)" },
					{ CCS_AddString = "Subtract (Second - First)" },
					{ CCS_AddString = "Minimum" },
					{ CCS_AddString = "Maximum" },
					{ CCS_AddString = "Average" },
					{ CCS_AddString = "First Only" },
					{ CCS_AddString = "Second Only" },
					{ CCS_AddString = "Add Random" },
					{ CCS_AddString = "Multiply Random" },
					{ CCS_AddString = "Modulo (First % Second)" },
					{ CCS_AddString = "Modulo (Second % First)" },
					{ CCS_AddString = "Difference" },
					{ CCS_AddString = "Power (First ^ Second)" },
					{ CCS_AddString = "Power (Second ^ First)" },
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ComboControl",
					CC_LabelPosition = "Horizontal",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "Operator"
				},
				SecondOperand = {
					INP_MaxAllowed = 1000000,
					INP_Integer = false,
					INPID_InputControl = "ScrewControl",
					INP_MaxScale = 1,
					INP_MinScale = 0,
					INP_MinAllowed = -1000000,
					LINKID_DataType = "Number",
					ICS_ControlPage = "Calc",
					LINKS_Name = "Second Operand"
				}
			}
		}
            },
            ActiveTool = "]] .. uniqueName .. [[_MASTERANIM"
        }
    ]]
    --print(s)
    return s
end

local Control
local nodeName

function mainWnd.On.NodeControls.ItemClicked(ev)
	node = comp.ActiveTool
	Control = ev.item.Text[0]
	mainWnditm.UniqueName.Clear()
	nodeName = node:GetAttrs().TOOLS_Name
	mainWnditm.UniqueName.Text = tostring(nodeName) .. '_' .. tostring(Control)
end

local hdr2 = mainWnditm.NodeControls:NewItem()
hdr2.Text[0] = 'Control IDs'
hdr2.Text[1] = 'Control Names'
mainWnditm.NodeControls:SetHeaderItem(hdr2)
mainWnditm.NodeControls.ColumnCount = 2
mainWnditm.NodeControls.ColumnWidth[0] = 200

function mainWnd.On.Reload.Clicked(ev)
	mainWnditm.NodeControls:Clear()
	mainWnditm.UniqueName.Text = ''
	fillTree()
	Control = nil
end

function mainWnd.On.Paste.Clicked(ev)
    local name = (tostring(mainWnditm.UniqueName.Text))
	node = comp.ActiveTool
	nodeName = node:GetAttrs().TOOLS_Name
    if name == '' then
        print("No Unqiue Name")
        showMessage("Please Write Out a Unique Name.")
    else
        print("Pasteing " .. name)
        comp:Paste(bmd.readstring(animUtility(name)))
		local nodestr = tostring(nodeName)
		local controlStr = tostring(Control)
		local nodeControl = nodestr .. '.' .. controlStr
		local ModifierName = name .. '_MASTERANIM'
		local Modifierstr = ModifierName .. '.CONNECT'
		if Control ~= nil then
			comp:Execute(nodeControl .. ":ConnectTo(" .. Modifierstr .. ")")
		end
    end
end

if type(node) ~= "userdata" then
    showMessage("NO NODE SELECTED\nPlease Select a Node Before Activating Script.")
else
    fillTree()
    mainWnd:Show()
    disp:RunLoop()
    mainWnd:Hide()
end

collectgarbage()