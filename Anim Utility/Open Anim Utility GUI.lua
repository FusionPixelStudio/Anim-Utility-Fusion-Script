--[[
	Anim Utility - A Fusion Animation Engine
	- Created by FusionPixelStudio(AsherRoland)

	This tool lets you choose an input to connect
	an animation engine to via modifiers.

	Consider Supporting me: https://ko-fi.com/asherroland
]]

-- Sets position as last position
AnimUtility_HVpos = fusion:GetData("AnimUtility_HVpos")
local AnimUtility_HVpos_x = 0
local AnimUtility_HVpos_y = 0
if AnimUtility_HVpos ~= nil then
    AnimUtility_HVpos_x = AnimUtility_HVpos[1]
    AnimUtility_HVpos_y = AnimUtility_HVpos[2]
else
    AnimUtility_HVpos_x = 880
    AnimUtility_HVpos_y = 350
end

local width, height = 370,540

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

local node = comp.ActiveTool
local mainWnditm
local nodeName

local g_FilterText = ""
local NodeControls = {}

local fuPath = comp:MapPath('Scripts:/')
local folderMain = comp:MapPath('Scripts:/Comp/FusionPixelStudio/Anim Utility/')
local folderRoot = comp:MapPath('Scripts:/Comp/FusionPixelStudio/')
local icons = comp:MapPath('Scripts:/Comp/FusionPixelStudio/Anim Utility/files/')
-- Gets where Script is on first use
local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	local strdir = str:match("(.*[/\\])")
    return strdir
end

-- Checks if Script is in the Scripts folder, if not then return false
local function ScriptIsInstalled()
    local script_path = script_path()
    local match = script_path:find(fuPath)
    return match ~= nil
end

local SCRIPT_INSTALLED = ScriptIsInstalled()

-- Controls all message windows 
local function showMessage(size,title,str)
	local width = width
	local height = height - size
	local msgWnd = disp:AddWindow(
	{
		ID = "MsgWindow",
		WindowTitle = "Anim Utility | Message",
		Geometry = { AnimUtility_HVpos_x,AnimUtility_HVpos_y + (height/2),width,height },
        MinimumSize = {200, 50},
        ui:VGroup{
            ID = "root",
            ui:VGroup{
                ui:Label{ID = 'msg', Text = '', Weight = 0.25, WordWrap = true, Alignment = { AlignHCenter = true, AlignTop = true}, StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);font-weight: bold;]]},
                ui:Button{ID = 'OK', Text = 'OK', Weight = 0.05, StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);]]},
            }
        }
    }
)
	local msgWnditm = msgWnd:GetItems()
	function msgWnd.On.MsgWindow.Close(ev)
		disp:ExitLoop()
	end
	function msgWnd.On.OK.Clicked(ev)
		disp:ExitLoop()
	end
		msgWnditm.MsgWindow.WindowTitle =	"Anim Utility | " .. title
		msgWnditm.msg.Text = str
		msgWnd:Show()
		disp:RunLoop()
		msgWnd:Hide()
end

-- On First Open, if user selects install, move Anim Utility Folder to Scripts folder
local function InstallScript() 
	local source_path = script_path()
    local target_path = nil
	local dirExistsMain = bmd.direxists(folderMain)
	local dirExistsRoot = bmd.direxists(folderRoot)
	if not dirExistsMain then
		if not dirExistsRoot then
			bmd.createdir(folderRoot)
			target_path = folderMain
			print('Neither Folder Present')
		else
			target_path = folderMain
			print('No Anim Utility Folder')
		end
	else
		target_path = folderMain
	end
	local success = os.rename(source_path, target_path)
	
    		if not success then
       		showMessage(395,"Failed to Install","Failed to install\nPlease manually move to the /Blackmagic Design/Davinci Resolve/Fusion/Scripts/Comp/FusionPixelStudio folder. Delete your Anim Utility Folder.")
        		return false
			end
    		return true
end
-- Anim Utility Modifiers for Point Values 
local function animUtilityPoint(uniqueName,Point)
	Point = Point or {0,0}
	local s =[[
		{
			Tools = ordered() { ]]
			.. uniqueName .. [[_VECTOR = Vector {
				NameSet = true,
				Inputs = {
					Distance = Input {
						SourceOp = "]].. uniqueName .. [[_CONTROLS",
						Source = "Value",
					},
					Origin = Input { Value = {]]..Point..[[}, },
					Angle = Input { Value = 0, },
				},
			},]]
			.. uniqueName .. [[_INCURVES = LUTLookup {
				NameSet = true,
				Inputs = {
					Curve = Input { Value = FuID { "Easing" }, },
					EaseIn = Input { Value = FuID { "Sine" }, },
					EaseOut = Input { Value = FuID { "Quad" }, },
					Lookup = Input {
						SourceOp = "]].. uniqueName .. [[_INCURVESLookup",
						Source = "Value",
					},
					Source = Input { Value = FuID { "Duration" }, },
					Scaling = Input { Value = 0, },
					Scale = Input { Expression = "iif(]].. uniqueName .. [[_CONTROLS.In == 1, 1, 0)", },
					Offset = Input { Expression = "iif(]].. uniqueName .. [[_CONTROLS.In == 1, 0, 1)", },
					Timing = Input { Value = 0, },
					TimeScale = Input {
						Value = 4.95833333333333,
						Expression = "(comp.RenderEnd-comp.RenderStart)/]].. uniqueName .. [[_CONTROLS.InAnimLength",
					},
					TimeOffset = Input { Expression = "]].. uniqueName .. [[_CONTROLS.InAnimStart/(comp.RenderEnd-comp.RenderStart)", }
				},
				UserControls = ordered() {
					AnimUtilityLogo = {
						INP_Integer = false,
						INPID_InputControl = "LabelControl",
						IC_ControlPage = -1,
						LBLC_MultiLine = true,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "<center><img src='data:image/png;base64,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> ",
						INP_Passive = true,
						IC_NoLabel = true,
						IC_NoReset = true,
					},
					HiddenControls = {
						INP_Integer = false,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 14,
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
						LINKS_Name = "Curve Shape"
					},
					Source = {
						ICS_ControlPage = "Controls",
						INP_Integer = false,
						LINKID_DataType = "Number",
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
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
					},
					Curve = {
						LINKS_Name = "Curve",
						LINKID_DataType = "Number",
						INP_Integer = false,
						ICS_ControlPage = "Controls",
					},
					Lookup = {
						LINKS_Name = "Lookup",
						LINKID_DataType = "Number",
						INP_Integer = false,
						ICS_ControlPage = "Controls",
					}
				}
			},]]
			.. uniqueName .. [[_INCURVESLookup = LUTBezier {
				KeyColorSplines = {
					[0] = {
						[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },
						[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }
					}
				},
				SplineColor = { Red = 255, Green = 255, Blue = 255 },
			},
			]].. uniqueName .. [[_OUTCURVES = LUTLookup {
				NameSet = true,
				Inputs = {
					Curve = Input { Value = FuID { "Easing" }, },
					EaseIn = Input { Value = FuID { "Quad" }, },
					EaseOut = Input { Value = FuID { "Sine" }, },
					Lookup = Input {
						SourceOp = "]].. uniqueName .. [[_OUTCURVESLookup",
						Source = "Value",
					},
					Source = Input { Value = FuID { "Duration" }, },
					Scale = Input {
						Value = -1,
						Expression = "iif(]].. uniqueName .. [[_CONTROLS.Out == 1, -1, 0)",
					},
					TimeScale = Input {
						Value = 4.95833333333333,
						Expression = "(comp.RenderEnd-comp.RenderStart)/]].. uniqueName .. [[_CONTROLS.OutAnimLength",
					},
					TimeOffset = Input {
						Value = 0.798319327731092,
						Expression = "1-((]].. uniqueName .. [[_CONTROLS.OutAnimLength+]].. uniqueName .. [[_CONTROLS.OutAnimEnd)/(comp.RenderEnd-comp.RenderStart))",
					}
				},
				UserControls = ordered() {
					AnimUtilityLogo = {
						INP_Integer = false,
						INPID_InputControl = "LabelControl",
						IC_ControlPage = -1,
						LBLC_MultiLine = true,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "<center><img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAABNCAYAAAAcolk+AAAACXBIWXMAAAEmAAABJgFf+xIoAAAgAElEQVR4nO2dd5xeVZ3/3+ece586fSaNEEggkRKqIq5SVAJKU0KxQMTFRiyr/Ox1XdeyuoptXVeCshYIzQhhQUEgKwrogkgLhCCB0NJnMu2p995zzu+Pc+fJTOa5z8wkGZDd+bx4wjz3nnbPc+/3fvtXWGuZwhSmMIWXAuSLvYApTGEKUxgvpgjWFKYwhZcMpgjWFKYwhZcMpgjWFKYwhZcMpgjWFKYwhZcMpgjWFKYwhZcMvBd6wv6VnzYmLIt654T0o6j7yWldS1f2TWTMvpu+2G/LfS11x/RzvW2Lv9Ex7vXd8LnIBAWVdF54ad125rdG7Fv3ssVLZeusS4TyE8dV+Wk/bjn1Hy/c+Xj3ssXny9ZZv0jqK9LNF7e9+WufHO/6k9B3/aeMjSp1912m8ze2vvnrb96d8ZefuHAAyCY2sPayJavWvH+cY4WNzi+5/VE/btcNtE5gmRPDsDWPd03DsfzEhQ8DBzUYf9OSVWv2meiylp+4sAIk3qNY+7Ylq9Zct/zEhUuBf5/o+BNAGcgAde+reC3PLlm1Zv/xDLb8xIX/BZzSqM0LRrB6r/6Qlp4nRX4a+SPOQqTyo9rYoOiV7rv6W8D7xjPm9p++YzmZ5vP86fPx9n0lXue8UW1K913V3vfLj3657S3f/WLD9V3zkR4TFDpUUxdNx4yiKzWUH75hxI3Se+1HjDdtgUgvOL7u/ACVNTdDOv9OYMTAfSsuMqppulBte5M97IxR/WxQpPTg9Z8Adplg9V/7kQjlKZltI/uqd9ado3jfVafv6vgA15z6cuOl0ok3rcWig+A9QEOCdc3pR30OY77mpdKJbawx45pzd+HWXD3rmtOPGsCYTyatyQJoPer41ae+QnupdKIEYxGYKJgzkTVdc/pRr8GYuxvujzXoMPjSNae/4mteKn3gRMafEIQEa5obNbFCYqNgv/EMd/VpR0VeKp1IhG3876QTrL6rP7DVWjtN+GlEpg1MRGruqxLbl+5f8R7GIFjdyxa/RuY77xK5FmEj9+LzOufh73XIqLZNr7+IwVu/8Y9AXYLVvWzxN2XLzE9iDdJPA7buOEOoPPZbAHqv+UBkg0AhJcJLJ84PEDzzZ0xUrn3vverCyBqjQCIEyObpiX2rT/ye7mWL2ybKdfb/8sPPG2tmYw1CZsgdcVbiHMX7rt6lB/9XZx+31Bp9iUpn6jcQYI3FBJUxx1px9rFPKz+1b2IDKbBhhNUhK858jVHpzOQQKwEYQxRUSbd2ZDAm+WURrymKiegQVpx1jPHSDYipkOhx7Mlw/OrsY/+g/NRxDdcSaXRQJdXafrAwNpkD211IAWYMh3MpMEGIUYrlJx0SLbntkURas+KsY4yXSiXvlxSYMCSslM2kEqzeKy80CCGE8hBCYjGk57++YZ/0/ONF97LFR3QtXflgvfODt/1rJHJtylrTgA/dAdU8nfT84+i77hOm7ayLR7zxBm79lha5dkkUggSr7bjG7PnF3xvpZ8W4Go+Y718/F21+7KtIT4CtMdJCJv8M6fnHYUrbu5kAN9y7/EIjfF9IPKwChGxIhGV6NLc7FlYuOfEhmUodlnReSLChRgflpCbDxjpBqwbciJACHVQhm8WTTdBIBNkNCAkmjNDVCpm2DqwlkYMQUqCrVYaTqhve8YZ9jdbrk4ipAKyw6PLEiNX1S06IZAPuQ0jQQYAlItPRgTUNxMXdhGOsGpwHrAAbhFhlEEYjhUxcz/XnLmr48nH7HGGiCktuXa0mhWD13/QVLX0pEQKhFAIPUjkwhvS8ZO4KIHPgCVTW3vYT4KgRY/76S38QUh4nxMTtBNnDz6S6/h7R96uP/bjt7O+8r/+mfy4JQVaoFELuIKaMN0pJiIk/MMamMOHXkPEvHg9hjUa1zEjslpr3asqrbxrXDdh/05e19JXEU9gwRKQ9RCpPas4rGnec4J7e+O7TtPRSiZ2U8omqZQzR2GNdcJqRXvINK5VPVC7gN7eAnrwwMqV8wmoRC2Tau2gUsiY9n7BUGHG/3PSeM64QSi1RCY9U/GsTVcYm4MNx07tON2qs/akUwUK6rXNCY08EAhBSYkwytRJCOOJZjTDKIKxGaInwFMtPXFhZcvujNVb8pnefcYnRwVLVQLyV8X1koyo6CjTsYR1W38pPVaRKp4WXBh0ilETgYYVBSA/VOruu7mo4RCqPzLXXnrC+lZ9+jRDyLoQUkGqkamyI5kUfY/D2b7+3/4bPvhepQPiAxZoQi0RIhZAKJi+2UghEPL4EBEKAFQrVtnfDjt70l9F77Ueuan/rv51b73zf9Z8sSC+TF14aWx5wtNDPYHSACBWZhSfvsYu4+f1nG+WlRdKdI3yfqFQcFw/0mwvPMqqRHkp5RKUC6dZ2p7uaJHlA+D667AhJdqyHXil3fcPQOm8BaL1Eqvo2B6kUOgzQ1YlxVr9ZepaRfirxdSKUR1Qu4qUzpJrq2pz2CIQUjoDbZLcCqRTGWkwQIJQBK5BaYZWH0AYpZY0y3fKBt5akp7LSS7bRIMEEEUYHREHAkltXe7CHboHeaz9yhfDTS4T0sHgIAVHfJoTysVYjpIcNK6T3e824xssceCK9Vy59B6nsL4SQwqoUu8DTjIBqnk56v7+j+tSfEMob9jwNSXbGMT67N01jDB9cSLAW2dQ5JoeTWXgK4YaH3w6MIFi9137kEuGnLxTSE0P7rkvbQUikLxAig2yZOa6XxHhw60eWNCQwQnqE5cKY49z+sQu+qaPgk16mvu7LxnJHVC6TaW1n/KzvxCGkR1gtkcpl8Zuakn9/IbFGj+KQOvZb4LgOv76VVyqPqFIZW+czDLd//IKlOgwu8RJ0g1ZIpJAExQKZtvaaIWIyIKSHMVHD50J6HjqKEKEGKZGewGoPIy1CalASrMfyExd2zzjkyHbpe1L69UmPFRKpDWFUJqpWMJUd3BXsAYLVe/UHDF7KsQtCwRCnoiRojZUSkWpC5Tsa6lGGIz3/OMqP/vpygtKExZVGyB5+JsHzD0FQhFQTCMfmCqFAiElkrnaCADCAQGbHtsqr5umolhkjlO8j9l0qUAqhPPA80BarI0jlySw8dezlNNChAdzx+Q98TlcrX1OpVMIACoQl3InzqIfffXbpgJCiOdHSpTzQIUYbMq1tY463yxAKhCGqVEm3tINuIL4qDxuFRJWRbdrmLQBsItOv0lmCwf4Jce13fOGDDwshDm24PyYiLJXJdHTUtVDuKUjPx0QhsoFYI5TCWos0gDRYJTHGQygLJkIYiRQKKzQzX/7qToxOHk15oAMiHWECjYkCoqBa465gNwjW9ssv0MiUFJ6PEJ4TeKQEBaZvkyNWSKTyAIFqnV13nHDjI3UJmfSzmOrYb+uJoun4DzK46ttYQFiLNRrH68aEdtIRi4VCOiJZLSLGofROzz8OU+zp7rn874WQabfv0kOIeN0Soq1PIvwUQnkYIuQYyvYaGlz3nV+6aKtATPPSCey7UhBFBJXSmNP8/osf1lIqKRPGUqkUQaWISDfh6cnjGlAKHUXY0CnX0Rq8+hySSqUISoURuhsvk6V177nJ40uJEoJqaWL37++/+GEtLDJpr5WfIqiW0IEm29EFkygmoxRoHT+/dSAVCIiqIQgd8ysSjAfSID0wWiGVwXqaWYf+XcPppJ8irJQx2qKjitOBVqvoKBxBkSd8ud0/OacivHRaqJRboJAQcykWDwnoqAxCIVQKi0X6GdIHnDBqrKhnPaUHVtBa56HKveqdDN72TcQepiGqeTrpeX9Hdf09KNXsuCtrqYmEk0i0bO1fUePoTKk30X9rOIaU7wIZ77uK915hrYcUwtHCKESkPGSqdWxl+xB0te7hFWcfZzA6URrId06juL2bjgULx5wi3dTqbVv9l8TzTTNmk99rb/rWPY6JxlbW7ypy7Z1Uy4Nk2mdS3PRsw7bZ9i6aZo/ULwYDA+igQmnrprp9VCaD1Yb2+QeMe03LFx3c5je1bJdSJu/19Jnkps+itGkDlf7ecY89UVjrOP9GdiU/34SXydI0Zx+EklgdITwfYS1KGlACa3xEzHERwLY1dY3+8Xh52l52YOxDVo25q3AUdwUTJFjdyxY/ILx0WhA/MIj47S7cgy8lKN8dVxKsRjbPRqgUqnn6qPGCJ+/Cluu7F3md8xCZFtANHYx3CUOioQ1i5bD0nWLR2MlUuiMsxHKoezsKOW79ETjluwlKEFXifZdOA6eEU7Z7HlZbjA4RYXX8ynZ/5BqWLzp4Xz+XX0+DB6h51mzK27ePqZsxlQoincFYXVcVJYQk2zGN0vZtDGx4xvn4TBKaZ82muGUz6dY2BjesT2wnhKRp1t4UN28YQbCKm55HN7gfM60dWKMJy4PjXtPyRQcv9ZuaLwGLMfXFu+ZZ+1DcsoHKYD9hcc9LHUMwWiOVAmziY5CfNhNjDUhBtacHv7UTqz2QGiEEUkm08UBadLVKVG1gFTWWVHMroY7QJbDVKjqq7tBdheGoDZmYgkiqwx1RclwVUrmHHRX/DdG2dbFS2wPlYwa34s95ed3hou6nQKUInr6n7nlv2nyni5kENB3/Qax1bgXoEOeA6uTuyYPjrJxIGB/xEvRCdZBZeIrTN0kFykMgne+vAF3sATzn/CoEqmXGuImh8Hcod5cvOvirfnPr0yjP2ah3+kg/RdOMvShu2zL2wNZCJjdqjKFPKt9CtnMapc3PEQVVJ4YktN2dj0qlyXVOp9jTjfB9yn29iW0z7Z1kO7qo9HbXLsPoiN6nHkcbndivde95BMVBTBiM78e0llRzC35z6yWJ+9PUQtOMvSj3botdKUqTsj/OAOR0VknnhfJo3+8AvHQWAehylWqp6CRDqQCDUAqkhwkCyr3b3G/a4NpkNoO1lpbZc7C2MpK7CissuW31KIZqQhyWEMrdxCinrxIqfvDcgyNrC1JYjFMoe9m6vlc2KGJKvchsG8Ez99X1fs8edgbRpjUTWeIo6MGtAKM4PNU8ndTco7FP34MZ2OKuw1oYQwG927CGofeEEDEBGydU83RU8zSivueoGTmGlO1SYaMqIpVF+LlxKdvrYe9jFn3+wLPPTzz/6JU/pv+5p8Y1VsfLDuGgt15Q91zvurWsve5yKn29HHTuhUw/bJzi6wTx8E9/QLq1g+1PrCGVy/OyN59L+/z6ESuPXHEJgxufQ5uRIrKfbeKwd34osd/qy39EYePzE1pXpr2TA858R/Jali8Daxl4/hmssbzszW+ftD168LLvYaOII5d+IrHNA5d+m6hUREcBvp8h0CWkgGr/dvx8BxjPOYpGGj+b45Uf+W7iWPf94F8ICgOkUhkCHeJ5rZhKP1o35q5gAgSre9mZkfBSsUXNg9h3CRmLfwpsuS9WvBknngQVVOucum/66rq7QAfY6iAmgUio5ul7hIAM3voN2s7+zqjj2cMXE254GJo6sdXBmnpp0jCcn43dGiYqgqbnH4dZfRPYoTcaRD3PIJTndGI6RHjZcVtkAYSfpnvZ4uO6lq68M93SyozDj05s+9i1Px33uE177d1wLBM4wtC+/wEN2+0OWvbZj771T2BMiLQe7fMPTJzr6VW/pv/pdYidFfBCNOz35M3XTZhgAQ3H3PCnO+iO9T5+Lk/XQYdN2h5l27sY3PCM0yPOrG8cm3PMIp69axXSRPFL0jEm5Z5eUi0dWK2c9bJS4uUf+FTyXt1yHdYalJ9CRyGt+8wdyV2FQ9xV/VCe8YuEUipULPqpIXFQIVDYOGxJVwZixXXMRvrZRN+rcMODCM+JIqYySNRTX6eQXnA8NpqYw91wqObp6P6NVJ+6u+753KscN2GjEGstwsvUuLI9jtjSJIbEQkCk60d/JO1Hat6rHXclJdZ6biwdAgqpPISfI73vKyc0pte1H8CHJnQtLxEUt26isr2nYTjJ/3VU+noIq2X+csk3E9ssePO5eJnMDhcYIdHVCirlY4OqI2B4eLl8Q8K6/rYbSeVbwRo0BkWT013pamwZrKDDsL4ViHESrO5lZ35UCKczQcjYBV/GD47n9ClSOXHHWuf45+fBT37T64EtYMFGAUJKwuceqNsuc8AJu+036E2bT/nB65ySfedznfPw9z4CmW4CXFydmSSCpQvdOPE5ZuWkSLRKmnJfLdB61JqnLXBcbKxsx/Njou6cG+sp2/XgViqP3VZ3PJlpRbXOPnwXL+tvFsXNG7Bh4BTlwk4u9/wSRXHzBkwYYoKAweefprh5Q912qaZm2vc/EJSHCQP8VAapJEJKBjY8h1CCav92Fr79vYlzPXnLdZS2babSu41Ia9rnzcdSIQqrmGqEDiOisMqS2x5JiKYfL4cl5LeRsYOiiD/Sj32AJEJC1PM0zjqowGqsjRLN9cHT92B1gIlKCC+FjSoECQRLpPLITMMsFmMvX6UQQlK876q65/OvXILItCDSTUTbn9utuRrBVArUqK+Iwx285FiqyqM31z2eWXiKM0YI0NUB5wfnZTC6itc6q74I/vgqbJjMqcp8x8wJXcxLAIUtGwgrFSc+T1Bf+H8FhS0bMEZjBURB2JDLOuzv/wGMdnG3Qw7LsdVbSgDDXkcnJ5RYf9uNZDqmgzUYDOgMplrF6CpRUMFWKuggSOSuYLw6LClFbA7Y4Xs1FLxrne8V1jjZXxusn0aqVF3fK4DqE3eAjpB+FmssQkqsCdGDW+u6P2QOfiPlh1Yi1PgtasNhTYRQKaJNjxH1rK9LSHOveBuFu3/s3AYmC1Yz9ANjY4tTmDyfLvbU3ZMh5TtRGaII4cduGSpP5uD6rgzBM39GdcxNXpvym3bhivYI+tY/gZ9Pnr6RiNG7bi1BcaDuuaduWYmXzSD9VGyu33NREy80ep96HJkQ/gO7vkdP3HA15d4e0pkmjA4YfP4Zips31NVlpZqayU+fRXHrJncb454t5Xts/+tjLHx7claoJ2+5jrA4SFgsEGlN5/wDMUEFHcTcVRARRVWGB0jXw5gEq3vZmZuFl3KuC8J5rQspY3HGA+XeXEIprNagPFSuA5HK1SU+4EQj4SksGiE8JxYKRfDU3WQPP3NU+/T+x1J55NdjLTURMtOKHexBCCjefRmtb/7qqDb+XofgzziAYMPD2HBiEfUTghBxtobYUphuELSqIyqrbyT/mveMOpWefxzl1Tch/BQmqsYpYgT+7NEZX6Ke9Y4jTshqKpunY0o9L3j2WQDpezxzx808desNdc+rVIrTfrwysf9DP/sBA88l+1Sl29rxs1l0ME53g79BhJUS6369gnW/XlH3fCrfzMn/cU1i/3u/989UB/vrnjNhgJ/OOLdKDWHF6bKO/9L367Z/xQc/w91f/zTWGqRUaB0ilEeuayYL3vS2xDWsv+1GVCZHWBjAYDCBh6kWMaZKGFSw1bG5KxjPK0fK6U7R7nQu7u9hvlcCou3PgFAI6SGlh6kOJvte9axHSA/VdQCqcz6yYy5q2gJk295EW59IXIbws5DgWDcmBGAjRyRMROn+X9Ztlv+7v0f6WcLNj+3aPONZiN1hihRCuvipJEhBuPWvdU/VlO8o8DJYqUgnJEYs3Xc1NigkhuCo5ulOrHwRIISkvH0bUblE6z7zaJq5F9mOLlJNLahUGpVq+MLFy+YIiwV0UCUY7CcqFWmdM5emGW4cO4le8y8UpJAEA3119ieDEIJMe+MME+nWdnQYEBQGiMololKR5r3mkJs2g1zXDPzcDhWCDaoMPv8MQaG+82t+5mwybR0ExUGk71QtAph34psS53/yluuIykUqPVuItKbrwEOAIe4qxIyTu4JxECwhPOHkfy/mrOKbXrpQHBc/qJxoJzxEphXV1JWY90qk8uReuYTMASeM/jTwHcq96vzdii20NkIYl6MneOruupZAkcqTftnrmDzt7JD+ihqn1TDw2OJMxRsfqXva5dGyCGEhQdk+5O82xNElQaQapPqYwv8phMUiD//sB4nnDz3/g6QyeVCOWEnlJXJXQWGQdTdei8rkwFqMNeiSremuHHdVRgfj08U0vIu7l53p8koIhUtEpeIQHOUoqwJT6HEWK+m8362OkLmORC9rFacDTvokweucNyGv8J3hiK4EJEqlGLz94rrtsoedgT/jZbs8z7jWgoiJkUZmGucxEkJSefQ3dc9lDjkdVMql9Mh31le2P/F75xg75qJeuvqdKexZROUi3Y8+mMhltc8/MNY5CqJKmbknJpcEWLvi51gM5W2bHHd10CFA1XFXQYgJNFEUsOT2R8cVltH4Lh3meyWUrImEQsia75WpDiJq/lgaoXzSB544nrknDDVtf2w0pphbF9YYF9hpIhcZI2Si20CjnPO7jSHrIICXwpu+oGFzaw26b0OiS4bw02AFqbn1la7VdXe6lDNj4oXKrTOFlwLKvVsbclkLl1yIDqqoTJb93jha7wyOu9r057tQ2Xwyd1UpOt33OJFIsLqXnflzIYd8r1Rs3IrTyKBc6uM4dQyANSEy0wp+ZlzZB3YF2cPOwE4weT/E8YIyzpAQZzkQUlJ59Ja6hGDyIHbQBSEQmdbGnI0AYQ1gqPz1jrpNvOkHYIJiXQfdcOMjmLAMCOfS0CBwV6ReNCPhFP4GEQwMNOSyZhx+NBjDrKOOIdVU3+3IcVeW8paNo3RXOgjQVc1EtdLJT4uQ5yPksIBUD+L8587THaJtTyGkwmqLlRKrvAmFhEwUqnk6dhfUS0KlsFZjrXY+YiaCKEQqL1E0nBwM6bAkwhpkLjl5nxnchpA+4CG8LJW19Z0+0wuOTxTBy6tvxFYGY4OIilOH1IfYg+n9p9yd/negtG1zQy7rFR/6DIe84wN1zw1xV16+CYxx3FXZYKqB87uqVJ0hbIJIvkulEs4bLPa9kqpmlbJWxfmXhONehOc8xYVMFKdsUCTqTjY/D4dI5xO5tPT84yndf+3EYgylh7AyJs8i/rhrMpUBqk/eRXr/Y8c/3u5ACIayjTbiFvXgFkjlMDZEWh8hJMFzD5Cac+SIdl7nPPJHv6NO/62Y4vaYg9uRRz4JdlctsDsj1hWKl7DP0xQcKn3ba1xWPS6qke/X2hU/B6UobXyeyBi6DjwEXS67lDOVXVPrQALB6l52ZnFHoLOPq5/nlOpiKL2MjtOxIJGeh0g3I/Odib5X1XV3UfzTfzYQgSwq1+5EpWxHXV8pcKE6lcdunaDF0CJbZ6D7NoCwCCGwCNAGISSlv1xLas6RE8pNtUuo+WA5D2FT7E7mSHWE9DOAxFiNwBVk3ZlgAXXHqKy+ETO4DXxnqLDWQAP/sgnXLKsDlwo3dDrOPaDEF5OYG2sK40MUVL728M9+8Pmj/uFz4+4TFAbZvm4NXr6Jas/WHdxVOUDvRlwwJImEUuaQQwn5RPz/OP+SdPmXooHNIBRSuRw6pjKINz3ZulZ98k73hzWjPjLT4nyBvCzCz2J1mBioG1fVmeBlCkcAvBwwNK9FWIMwFikVxf/5+QTH3AUM02tbCSKdrDeyRsefEBl7x5tCz7gDs6PuJx1XHKdjdsxxA67U3x23BouQzqFYoBCexE8le2WPiZgBhv/FEcsvERvH6Zf91xe2PfpAoi6rHtau+BlhsUDxuacdd3XAIVgG0Xr3iBXUIVjdyxbvK0ScBUAo9/8hcVDGrg3xgzCUlYF0Myrf7gKV68AGRWxQJLXXwpGfOYcjm7oAO8L6J/0MlTX1LXgAmYPeMGEzvLUg8q2Ok4i5RWKxVngZou4nE+MZ9yxErQZFkuf5DmiEVC5bp3F5s0t/vmLMGSqP3RbHLeJ+J2NqgeaJq/LH9NmrD0/F94mzIst07FGvJs4duWSNjlpJK14yD/WEYa2LuX2JoNyz9R8b6bKGIygMsu3RB5GZnIsZtAZTCbHVPfNj1nnq5VNInI5IDN2MXvyWdr5Xum9jXCBVYYmrJTcI4i2vvgmQmLCKCWMfDCtqaYKB+OZ0+aFsUMAUtiWOl97/WFRzcvHRurDOtUG2znLKdxPFSngDJkAKRemeX0y+1VAOZWugll4necHEhGpI76Ywg9vGXGP1iTuw1eKOeE8BVk6CTsmaOPhdYKxBplIIqVBD3PkEIT0fi0BgXKrnoXvifxOEQGUzqN3hQF9gnHXt7786Xi5rB3e1nsgYpu1/0C4p15Mw+q5SUtYCnYc4qDh3uMXV87M6ANSOqG2hyB52RuIkjnOx2KCMtRqpJFiDBbz22eA7YmeHmd1NpZAoFgIuFfB4kxyFZVe7zQJao9ItMYc1pGtREHvtF+6+bHxjThgxxzFUfUXKhnm+bFh1baXc4UOGxVYHE10cwIU+2bBcm05AzSrpgq8TVudn6F62ONkDMIYJ3W8kPR+UdEHFUqJUBimUO24EaoKe80aHMYEVWHD31iRWen5RICUqnXEhNQlVev5WMR4uy3FXDyDTWWcZLO/5mNwRBKt72Zl3CKHiQOch3ysnDgo5FIbj1SplWCyyaToIEq16enArNio74jKU4N7YWI+Ek9Xih9iasPZClekclTW3JC4896p3jj/fu5+NM6HGc6dzWG1iVwfHaVkTIIRE96xPDIXZPVhGuDUYk5i8D4CwjPAyNW5QSOWKFCif6ro/JHYr378i9p53Cn4rBMK4AhCN0st4XfMA3jVWxZrqQB9oG8eN+lgLynf3hbEGY0JUPoP0VHKJqGGwWrv7DBnvjnH/WU1ULVsh5eYxB3kpQHmoVLb2kbsRtfFi4Kxrf//VnsdXN2yzdsXPCAqDVLZuRE9SbYSRd5SUx48sMuHV8l7Vikx0rwesI2g6RJf68FpmJj7klcdXQVDG+hmEtY5oSIMUjnjVOA4sw52sbGUAY01D4iHSTdhqsaGSHsAMbnE6A+XFOneDapsV53J3b3VnhpfItE/pz8vJvXJJ3bFstb441mh+3ftsrGAfKkLh/iSqJl6f1SGqdSa67zmsVE40HOJ4raH80HV400YbOXTf86imTldnLwpizz8A4rYAAB8oSURBVHrHqQkvnTifKW5H5trmmm2NbzRrrbMKK4mUHvge/c8+TfNeczHGj+PkFYWtzzH39acljlPZ3oMxFuXhXpDY+FZwfnK6EtjFy2+Vv/3wufXrab1EYADhe3g7VTqWLw0OawSLGxaLm4BZSY0HN7pcckGljEqo7Ly7GDFqYpEJOVRkYqjii4Swisw0E/U9R9D7LMEz9ybMkEWmMrGuKC5bHVvqrLGgLF7LdKJCN4QBVgcIL48p92N6NxDe/JXExYtUHpltIdq4OjFjKYDw0ngd+wLCpaESCnSEkB5GV6nl1rASqVNEvc8wkDCv3zxtp7FT2KBA6d4GynChXLaJ2CdKCIlKZwk3PUq46dG6XWSmGa9rnhNlhXUB5tYgpY8p9VG6r046Eenhd85z75NU3tUoNBpUCi/bRrBhtcthXw/K07ZaXBRVcg2L3vn5Jky1ipfJosOKKw0lJToo46WzaK3QUYD007Tskxzx0PP4apTvO2IqBFYJV7AojIgqRfOmn9340tFKJ8CEIX5CtWwxGTrFPQphz7v9kRGLNHoM9tsagoH6aWwaTyXrpzmtgxrB6l52ZrV+kYkhCxAuHW9QQeXbCasDmGKlvnLVAFKDysSFStmhVB8qJ2osSOPs+ypd09dIP03YF2f9VPXGdpVtZK4NohBdiM38dawuQqWRuU6QAmsMQrriGBhX4FHkO6BvE0JqED66PEAUxbUKdxpP+nlU2yxnAdtWAC+F7+cJCpsS58eAP2MBQnqEPU+DEPjZNoKBjZhgoP6avSxex95Y62GtxevYh6jv+ZryPerfMHo+A6p9tuMgpXK6wUwbYXE7pPPYch9Btb/+fiJt5wVX1E4EF412Qh2OTEsb4WA/GIOXzmGiAIOl3LMFa6F51t7ITAovnW7oWFju2RoTK4mQhta588BUqJT6q6ddesMumiz/liBI5ZNFfjuSefmbgpXYt/3mLy8IRRVSfv7cWx78l/G238FhSZnaUWQi9r2SyinbrYerdVDEWk04mGzBwwQ6ZiliImSxGIQ1rsiDxREMaWL1KmANnpch6N+EKSVTaJnKoqYtQA9uxAx0J7ZDgMw2g/SwOkQIH0yI1SIuPBqLhmhU+2yinmcwpfrjCc9HNk+vuSBYK/By7UT9W2iUEk5lmyDf5a5QSGSuDTOwhSBBpEQqVOssF45jjLOsKPe3EopwoP6eK5mC1jb3xYJ7WyhIpxFCuGwadWGtDcsndy1deevwoyaK2PLQvYnE5uXv/xS/++z7UbkMYaWI56VQWIKgSlgqsr1UwBRLzHrV8Q12B8JSESU9kAJtJEI0segbP5hsT9HJrovkIAQ9jyVwsjFSLclhWS8qhNRvue6PL0RyNHvOr+6aMFH0ALqXLT5LqPSIIhM136u49h3GonKdkEtIFqbSt7ac/Lk3di9bfBzS+4OouSzYHQ/SkKVKeIBFxI6BNgoh04SfSchcYG0sFqUhKqOy7ahsPedRSdS9zunetAXh0hBbrcGLlc9x6IjVxmU7DUqo5mku5fCIoRRmYGtcyXroGlPOOz7Tgp+UFiYKXMCx8l0QkHQcnUw3IafVcRSVCt2/xRFRa4EIa1POy9vGFtlsG362bWS/oIwu92M9P64oDeAKgAghsZUCqn1v6vBwFpU6tuXkz/2x3vKFlH96etWvX51EsPIzZzPn2BN57u7b8VIZZDZLaeumuLyYxJSr+K1tvPKiL9bfH1zK3nLPNpACYyy5aV120Td+MKlvdCmkVZn014AvTOY8OorG5dKhUsluQBOCEHuECFsATz105hW3HrHbaxoDUgj75qtW7dLv7SipkCtGFpnw3INmcbqmoJDIwAqhdOsZX6tR5K6lK+/svvRsdoh/MaEy0hGd2DwvkBhtIGoQYiOUK8vuZbE2gjAx24DV258WrhBqnP7GhAjjgxqa32JlBFYiohBrwvpWfgF2KPBYDW2Ph7UCW0leqxUCittjp0nHOWDBJHFUAszAFte+ttcaawXSWkwUgB1t1bNCYnqfQyjnoCmGyoUJQPjYsIqlfqyWUOqu1jd9LblKAPDGH1z5mv/+9PtsUvwYwOHvuYj2BQfxyBWXMPDkWpSfcoVzvRRt8w/k1Z/4SmJfgL/ecCWZ9k6ichFdrdiT/+3qSSVWQgp92s9+7d38/rOTFaK7iahUHLeYl5s2A7UHlO5SCXvaj2+Sd3z+g7stXwrPf/+bL71p2W4vaqx5hNSn/ew3u8zBuY5S7VRkAlw4SxWr69/8Fmnaz/lufcWocxySWOvEQEwsFlrnaGo1Nmzw8CMQUbXmjGrDBg5rwruh7exvL+5etvibKPVJYQRW6Nj1wiBEFPsyRQjpO6/7hBtLF/tBOMW22xdHxG2DQhEWJ3YJlXLFTGMXEBoQDl0ugy4ilF/TrYHBWoXQIaZOzi+LMqb3WckQgRPuqJN/peNSk4RUoXTb2d8Z900SFAusXfEzDrvgw4lt9jn+Dexz/BsA2PKQM7i0739QQ0IFjrvqfXItUaVMWK2Ys67+3SQq1y1Cqc2n/nBlomVrT+DwCz7M/qecNa62f73hKrY+fB+Zto7dmlN6nn7DD6/ebdFNSGFPueRXL4C+yiKUv/bUH1570O6M4nUvO3O9KzIhd3id6wii+kTCCmHbz71krAv8pMV8e8iNARWLhcIgGmQosEI4Z8o4i6YIkh3PrJRB+9t/VOOru5au/FT3pWd+DGkUcaI+JKAliMgFa9cJ/nWuYFbbynaFTIHyHDmTEhEGENYnAlYIawrdAuX6OGuqcPPUCYGxAEpt1v2bZwjpC1Qc54d2hMpGiDqFEobvd8+PzxmSr11fKV3q50p9ztNKYdvfPuZvNQo9jz00V1crT8859qTEUurDMd6KxEFhkAcuvRgvl6PQvcWcc+3vJ9USKP3U50/67mXjVujuKvIzkysm74yN99zJ1ofv2635pOdvWPSty/berUEAIZQ98Xs/fUGU6zKVPvukb1523W6Pg5T7IpUTaazBhhVsVMHoap1PsHIcxIqupdd/x5Vhd5wDACbABuW642pdRQclTDUmkjrAhklrqNq285aJ4cSqNu+F13s2jruzRseuE6HzsK97TYFpP2+ZMIVtNc20S1+ssWEpcX6jw8/X9kEQV3JutHdunva3/ccsrDnHrdHs8EGLqqP2Rrt5vjVqv208H84RNGGfrDHhMbtCrACWrFrzTK5r2pY/fv1T9K5buytDjEJQGOS/P/1edBiw5YF7q5NKrISwJ3zzJ2LRN/cIsfqbMuepVPrze4RY+Z5e9K2fTD6xkmrot9htYgXgUogaA6aa+MtYIYKud189MS2hNS7MUGusbpBfXsjNVldnilgMa+C9bjvfc83YG2z0pVZwoTA0yvE0eqwh66VpEFEu5DOd775qbq2LANG4z6h5upauvK770rMsWGF1ALoeVyW3d737qlHWDbehtnGaaCFu7Xz31W9MbjA+vP7rl8687aLzwwcuvdhbcMa5zDlm0S6PteWhe3n4pz/AaM3J3/3FpFrphBD2tV/54R55EI3R9rVf+Q/5+y9++EUnWsYYXvuVH+6RvZOp9LbXffmH9fNA7UEIpexrv7JnjSle1/tWTMoN1HXh9S+KZ1zX0pVLgaUT63P9BCOp437v3bW967rwul3am673/eoFTRB10vcv93//xX/YuPryH8169o5bmH/6W8Yt/oEjVI9d81MqfT1k2jrsSd+7fHItgZ5vz7z2jj0yh/RS9q03/O5vw7tTCPvWG/5nz6zFmhWLl9/6lj0yVgNIL2XPvHrP79+LU4xuCi8ZvPbL/77X8kUH75tpbXv6/ksupnXfefj5ZtIt7bTPP3CEkj0oDNK7bi2V3m5K27YQDPShsjl6Hn/knUtWrbl8V9cwpNSvh6jsuHc/m9en/+d/jXk/NxJxyz3O183PN5vTf7JyhMi6p0Tj4lbnaCw9v7d33drExG6lrZuH2tkzLr9lzAe/0R7pagWiiGrf9jcuWbXm1sSG40Dj38LpiL10unzGFb/N7c48SRC1Ci5TmMI48Nt/OPfPXjZ3VGz1wcukcRYHS1goID0Pa40td2/562mX3Ti2xn4MLF908BemH3ZUojuC9DyKmzaufvMVt4wueT16rMOmH3bUQ43aVLZv3famn98yQly6+6sfD0o92/ZI8F9YLtH7xJqPAT+dfthRDcOgoqASnvLDa8eMkr79o+80toEvlp/N29f9y492m9sZ67cwWhMM9N78pp/9JrnA6G5iimC9gLjpPWeYdGvbmGJdVCppIYVSGZeiJSqXOOVHv6z1W77o4FUzjjj6hOG/XXHzxrsXX3lbLTH9r99zhkm3tgtrNDoMSLd1EJWK9qTv/kIC3LDkDVGqpVV52fhFaAwnfe/yUWv7788uNVhEMNiHSmfQ1QqppmaiSnn1G76/vEYkli86+Kw5x5y4olroFwAqnbEnfH3ZiIfk+vNONE0zZ9fmEFLaEy+ub6Xq/snZUZz7RwwRRPdISosOw66l16d3tD3nEgwX1jpLa7ve+yvVfek5I/MPWT3YtfT61h39zo4wwzJBDvX78TlmbFW7NV0X/sqL5xDD+v9tiJH/SzElEr4A+K/zT+4tbt3Ylm5tZ/6pZzd0Fehdt5bNf/mjstZy8NvfA8Dj1+2Qpq5909FG+r7wMjkOeusFteP3X3Lx0QC3fOAtRihPNO01hxlHHE37/AMJCoNsffBeqoN94jdLz7Yt++xHuWcb7fMP4ICzzndzXL98xDpWnHpk1LTvApVua6fzwEOZcaTTXQWFQbY8cA8Dzz516G0XvcOc9P0r5K/OOd6odFqUe7s54r3/D4DNf/mTuO3/nW9O+t7l8sYLTt9U2PzcTJXJkeuawfzTzhm6rrrEe/sV7zEy3SZ2MA3OIRjfgygQBOVUz3++3dqwWpW5LmS6dZhBSGK1Fdsvf4+V2Zg2CZwVt1pqGTaHlum2YcTFYnXk+mXGCpuxGC3UiDkw2Kg6lYR+kjFFsCYZqz75blPp6xFD2T/b5x84puJ681/+SLZzWq3ds3+4lds+cn6osmnPDPP2HzGOwL/hvJOsl89z0OLzRhW3HLLyPfXb63nixmsByHbNqI3x3F2319pef+4i07JgoZhxxNEc9JZ3kWpqJigMUty8gRmHH82cYxYRFAb58/e/LG75h7fbYLDfORwPW9OMw4/mvz/1XnHbRUtMMNgrhBCgNblpM0dc187oW/ExIzNtLo+0jR1jledSCRV7sEpAxjnmypbZaTE877v0XI62EdZh5zRMWMZ6Ht2Xnq29jn2EzLTUiIuNIxrkOPKrWWPA8/DMsHmVhy33u6SLU5hUTBGsScINS042Xj4nUvnkQhO969YSFAdGHStu2USmo2vEca1DT9HAs8RawnKRWUcfO4JYFTdvoLBlQ41I9K1/gt4nH6OeymPV5z5s+tY9LNrmLaDrgEM5/F0fAeC5u1dx3799hUzHNHSlzBt+cBWppmaO+fy3uOPzH0xc0qs+9s/c9bVPCKn8OPIoOePpwC3/shQT/EhmW0cmc7caK9JgImS6CWsirNGo5r2gVoZTgoiDvofHW0kfoiomqmAJESaFP3v+Tu4sPlaBMMlFZofGskEV6fuj5jDF7Y37TmGPYYpg7WEsP+mQTal880x/jBAVgAd+8h0233f3yINKoZRH50GHTnjumS9/Nfu+/pTa97UrfsGaay/DRBG5rhm07rufs1KJkTRhCL1/fUBIz0dXKhz01ne7Y+vW8sAl30QHIVZHeLkm7rn4HznuS98D4KC3XkBQGGD7E6PzeuVnzmbOcSfx/J23UxnoxQrjOJSdsP0/36ZtFMqRi4qz3Hoe+Dm8fAc23YLoXk9U3l4jVUL6Ln3QTtEFqa79wPMxsgkhQ2yxDxuWCTf0xR0FUghMnfXsDJlqctleox2REkIoRDqPbN93zP5T2HOYIlh7GMIybp8uL5Nl2qGvABz34Tc1s/n+P7Grwffdj69mAW+rfbcYctNnkc43s+WhP6P8FF5Tg9qLFjJtHez3xsU1d4Wnbl1JdsZcUm29VLf3YcxAzdMenOhXj4ssbnZ5uw5+67vZfN8faZu7gP5nn3RB3cPQu/IzRuQ6RxWLlvkObGUQG5Tw/BxEVXTPash3Iv2h0ECLLWyF3IwRub5Vrg1d6oVAI9uaMKGBbBsyznhhdYCoDmKz7cixqi9JhenbQO7V76qlAS/dfw16yxOYSmGqXOwLjCmC9SLCGkO6dYcrTlQusverT2DjPck52xvB93xWX35JTfw76JwLKG3ZRGHz80w77CiXVaFBIQpdKSGlovNlOwqzlrZtRkqNap1BYetWKJcRXTPoXbe2ZjzwcqMJVmHLBh5ZvoxF37yMIy/8BH/61ufrzimVJ3LHjxYrbVCkuv5/0P2bwEtBqR+jA3ILT6kRjvKDvyIc3IY0EU2v+0itX+mBFQiZwpoABrciUnny8Rw2KFK85xfIsIzonEf2kOQ0zuCIk+nbgNc5r1awVj72W6JJylk+hcaYIlgvIg5754dG6LB6163lrzdcuWuDCYHwPEwYcOtF7+CYz/4r+ZmzecWHPktQGGTtr35B7xNrCAsNMk9Yl8diuBVTKA9TDZDCJxroByFIt7aNWHe6tW3UWE0zZtO95iE2P/A/zDzy75j9quMTw66GV64ONz6CbJ6Oap5Oau6rsEGRgZu/Cri+wwlH+ZGb3Bqz7URb1pI90lkfde9zVJ68G2EkRnrkjzq31mfwjn9DlguImQch853JlbeHcH+dVNRTeNEwxdG+iBiyGA59WvbZj8KWjbs8nokiwsE+/KZm7vzyR/nj1z9NcfMGUk3NHPb3H+LVn/kGRod0Hjimj+XIcYMQbEjNcrezGGVGK8TyM2fTMf8gHlh2MQCHv/si0q3t6GpjS1rhDz9k4OavUvqLIxQilafphI9iveSyYXrbOqpP/bFWrzF75Dku8L7Sj8y148921xv1rEf3bQACTHlkZls9uJVw4yOjPkIoZOtuxxpPYQ9himC9iOhdt5YtD91b+/z1hivjituCsLgjX1i6tR0zLM2NEMKFW8QICoOEhQJYQ7VSZfDpdQQD/RR7tvL7L36YR6+8FIBUUzPHfuHbieW3hJRIzxtRMNNqjSWui6gNCCh3j6y8VemvbyUTUuLncty/7FsAHPrOD9L31F8b7olI5TH9Gwieu792TDVPR2bGMGIEBQp3/bj2temY9znu6tgdYaXFP/0M+p6FzgOxO6UNKj+0koGb/omBm77IwE3/WPuEGx5C6kkurjuFcWOKYL2IeOAn32HVx9/Fqo+/iz/+y6dd7J3yUb6HSu+ow7DX0cfjKv5okOBl8zBMTd375GNkuzrJztyXbEsrQRRhgPKm57FG8/yffldr2yhvk8AVzHVuDw5Ns/YmqpbimpQSL5tHKH+ED1hSpRQdhQQD/Wz+y5/oXbeWGYcfzcHnvnd8mxMF6MGtO743qCwOIPLTiLqfqpUx8/c6hNYzv4lqdlE2lcduxVYHUCLlco/VzfjpsuEOGxWZakZXGmQbmcILiimC9SLCy2TJzZhN69z5NO81h1Rrp8uGKiSFTc/VOJ2uAw+ladZelLq30jR7Lpm2Do5470dr42x96D76nn6S3vWPIT2Ptr33JdfRRVitUtjwLLmumSPmNVF9nyOZy1Lp285j1/60dmzuCafhZTJE5QAP6FiwEOHtiAt+6rfXo4OErLRmBwG457v/BDCuNDX+vq8CL10jNkDd5Is7Q0hB8Y87KncP9bdB0em7BjfDrAMg5SN24jKzhy+m5fSvjPio6QuwURXVOeW68LeCKaX7i44IIV39IGMNXq6JTEsrKpPl0asu5cj3fRyA4//5BxQ3byAoDI5QigeFQTb95Y8I6dE6ex8Ou+DDNe5ny0P30jRjZDbMZ+64JVn5ncmjfB8dBLXKOe3zD2Sf153Chj/+jqa5C0jl8xz7hYtrcz9583X0PP5IzdN9BKx1dQuBVFMHj171Yxae+77G2yGd82d6v1fXDoUbH8FUC1hrB4CE6h8OwktRWXsbmQNPqh0rP/JrbGEbItuG3v40sm2fWhWkIahY0b/z+oFRPl7Jk0PPT8/bSaGn6XzXNVMhO3sIUwTrRYY18XNhnV4b5WG1ptKzjZ4oYs01/8nBb3NOnPmZsxnuRdW7bi33fu9LDGx4BhFpqjuJZjuHAG156F7WXHMZ/c+sq7sWYwy6WqXSs5U/f/+rHP6ei5hzzCIOfuu7mX/qWyhu3lAjlr3r1nLv9/+Zwqbnk6/NWrQ2CCEpbd3M83etYu7rT20oluaPPr9mJQSnKC/84YfohDJno+bUIen9XjPiWGrfVxKs/x+UMWhdRZS2Y1Ijc6rrwa2YYSJo1LMeG1WQnsA2KD1Xg1CoYTGIVggwGlMeaNBpChPFFMF6gTE8r1I4OAAWtLZY44pIdLzsYEqbn4NIE/T3svnBe3jurtvZ93Un14hFcfMGnrnjFoJiAZlrQ/As6fZOMJo/f/+rZDu7yE2bxd7HnECqqZktD/65Vvgh095B/zNu/uKmDbX8RoWNz9O+4GUMrn8KrCMya1f8nEeXL2PuotNrcz/12+t59s7biUoFrI5om7uArav/UrumnfMltc6bT//TT6GEK9hx51c+xpEXOq6xtGUTzB2dEsoMbiV4+h7C5x9E9z47ytk0CSLTQmrOyxEpR9bDjY/g73UIXuc8VMc+mGIPFEJ0UEDlRhKs8kMrqa75LWBRnXOxUYTw09A6F4IxdFgqhVA7ssAIqSCsYKtTxGpPY4pgvUBIN7USFgvc/6N/rR0Tfop0vhWhA6LARyinC8rNnEP/+r+ihKT3ybXYcpkHl13swkNwVkLf92nd/1CkkHQd/gq61zzkypGFVSr929n2yAOsv+0GsBYpJc1z9sPPNyGbmlB+hlS+iY33/oGN98ZOqlIy48hX07TPfm5u5TGw4RlsqcQDyy6upZsemjs1beYID/dUrpntax9m1cffVTvWNHNvUs2dpLJpgmIJpUN6n1xbayP8VPWIV502QpteuPNHmP5N+DMPxBiDUGmEDrGSZWjOTdzggc3YXDvZw10cZbjxEQZXfYf2t/3AuUYc8z76Vn4GKSXWKEz/RlTzSN3eUMiS7lk/7t812rR6xHeZakbM2B/iSkvWimRP3SlMGFNK90mGVJK2+QehoxDpp/CbWsh2zTDn3f6osFpbE1aIwio2CAgrZUy1iqlWaN7rZTTPm48plwgqJYzRSKmY9orX2UzHNDKz9iGMKphSAV0eoH3eQbTtv5DW/V5GVCxiopBUWzsqmyfdGetmpED5KRAQlAr4TS2kmltp22c+bfsfhAkqO+beZz9sUCWolrFGI6RkxiteX0X5kN1BqKTn0bzXHHQU4uWb8Zta8FvcmOm2DrAB2fbZCGspbN6An2+uXf+5Nz8wqiS98LPOCTYV5+kS2I7zfya63rvi/Y322aSbaHrth2rfi/degUilKdz9EzdMKk/20DdDKodA1vf4H140ZceK8FpHEjYbVuIAaDOiXap9b0xYgtDpCK2g2PXeK6eYgj2Iqc2cLFgQSlEtOH+q/MzZSKHMyT+6pmZiO+/Wh+XVpx5pKSsCC54JMTpEVhUKn6gIzfvuh7SKSJf0qZes9K4+9eXWy2ahNICo+kSpLF4oEKKMRIEH7fMOIrTF6umX3JC55k1HWwDhC0wloFDZRH7mbATY/mefEl4mS7U8iGcCjA6QFYkiRaSgae99kVYS6Yo+9ZLrPYCrTj7SjacEWEm5bzsynSE/czbK87b2PvXE9FQuRxQE4Cv0oAHbj9fUTKq5bcT1jwUhlG1967+P+VKV0/fHa9u7FrJTeexWwCDL/eje59GDW1HN08kcdBLVJ37nXtNm5LDZwxeP0n0BlFffSPjMyLJcuVeehz3sjJHtHrqOYIPjtoTysMr7Vsd5P/7UeK91CuPDFMGaBAgEUVgm2lYeOmDP+eWddR+8t//mAXHlyUcYL6oKXc0g/TJCyNijXKC1sef8ckdhhbf/5n5x5RsPN9LzhacUpKpEnnB9AF0NzTnX3TmMKBhsGFHqrlUys0p5F595ze8+BXDlKUcaP6wKXU0jfd/Vp8SCFOho5NzuWiwIRXVgkCrO7UIKYc765R8UwPITF1YiJdNWKoIdlbLtOSvqX38SLN6IiuINEVZpeo1LdmiDIpXHboOBTbRecKXoXrb4DYOrLv5t2+JvApA/5n0U7vh3xE5VtetaCYHK46tGHRsijCPaPfbboZXbltP+aUpymSRMEaw9jPNuf2TCN+t5tzwoAZYvOvg1CHEz1q5ZsmrNqxPb//ah2hzLFx18FoKPLbl9zbH12r7txvsamtTPu/mBobn3RfAAsGnJ7WsWJrU/9+YHG4635PZHR4l5Y2HI2XMI0s/olpM/U/fejIbrl8Iy3qyFVrXMFFG3O15d9wes59n2C66QAF1LV97a96uP2fJDK4U3bX48gcQIhShsGzX3zrBBCaS0Uc/6htdtgyIoz3a+66opYjWJmMrpPoUXFd3LFl8KDPcmXdW1dOWFCW3PB7407NBm4NGd+m/uWrrymDp9n9zp0LeAT45jiZuB04C/jNWu3rxT2LOYIlhTmMIUXjKYYl+nMIUpvGQwRbCmMIUpvGQwRbCmMIUpvGTw/wFYMxBwuVEjVQAAAABJRU5ErkJggg==> ",
						INP_Passive = true,
						IC_NoLabel = true,
						IC_NoReset = true,
					},
					HiddenControls = {
						INP_Integer = false,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 14,
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
						LINKS_Name = "Curve Shape"
					},
					Source = {
						ICS_ControlPage = "Controls",
						INP_Integer = false,
						LINKID_DataType = "Number",
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
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
						ICS_ControlPage = "Controls",
						INP_MaxScale = 1,
						INP_Default = 1,
						INP_MinScale = 0,
						INP_MinAllowed = 0,
						LINKID_DataType = "Number",
						INP_Passive = true,
						INP_External = false,
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
					},
					Curve = {
						LINKS_Name = "Curve",
						LINKID_DataType = "Number",
						INP_Integer = false,
						ICS_ControlPage = "Controls",
					},
					Lookup = {
						LINKS_Name = "Lookup",
						LINKID_DataType = "Number",
						INP_Integer = false,
						ICS_ControlPage = "Controls",
					}
				}
			},
			]].. uniqueName .. [[_OUTCURVESLookup = LUTBezier {
				KeyColorSplines = {
					[0] = {
						[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },
						[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }
					}
				},
				SplineColor = { Red = 255, Green = 255, Blue = 255 },
			},
			]].. uniqueName .. [[_CONTROLS = PublishNumber {
				CtrlWZoom = false,
				NameSet = true,
				Inputs = {
					CommentsNest = Input { Value = 0, },
					FrameRenderScriptNest = Input { Value = 0, },
					Value = Input { Expression = "StartNumber + (MasterAnim*(RestNumber-StartNumber))", },
					InCurves = Input {
						SourceOp = "]].. uniqueName .. [[_INCURVES",
						Source = "Value",
					},
					OutCurves = Input {
						SourceOp = "]].. uniqueName .. [[_OUTCURVES",
						Source = "Value",
					},
					MasterAnim = Input {
						Value = 1,
						Expression = "InCurves+OutCurves",
					},
					Start_EndSeperatedHider = Input { Value = 1, },
					SeperaterButtonHider = Input { Value = 1, },
					FramesHider = Input { Value = 1, },
					CalcsEndHider1 = Input { Value = 1, },
					CalcsEndHider2 = Input { Value = 1, },
					CalcStartButtHider = Input { Value = 1, },
					USERLabel = Input { Value = 1, },
					AnimationControlsLabel = Input { Value = 1, },
				},
				UserControls = ordered() {
					Value = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "ScrewControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Common",
						LINKS_Name = "Value"
					},
					InCurves = {
						INP_Integer = false,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Common",
						INPID_InputControl = "ScrewControl",
						LINKS_Name = "InCurves",
					},
					OutCurves = {
						INP_Integer = false,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Common",
						INPID_InputControl = "ScrewControl",
						LINKS_Name = "OutCurves",
					},
					MasterAnim = {
						INP_Integer = false,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Common",
						INPID_InputControl = "ScrewControl",
						LINKS_Name = "MasterAnim",
					},
					AnimUtilityLogo = {
						INP_Integer = false,
						INPID_InputControl = "LabelControl",
						IC_ControlPage = -1,
						LBLC_MultiLine = true,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "<center><img src='data:image/png;base64,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> ",
						INP_Passive = true,
						IC_NoLabel = true,
						IC_NoReset = true,
					},
					USERLabel = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						LBLC_NumInputs = 13,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "]] .. uniqueName .. [[ Controls"
					},
					In = {
						ICD_Width = 0.5,
						INP_Integer = true,
						LINKS_Name = "In",
						ICS_ControlPage = "Controls",
						INPID_InputControl = "CheckboxControl",
						LINKID_DataType = "Number",
						CBC_TriState = false,
						INP_Default = 1,
					},
					Out = {
						ICD_Width = 0.5,
						INP_Integer = true,
						LINKS_Name = "Out",
						ICS_ControlPage = "Controls",
						INPID_InputControl = "CheckboxControl",
						LINKID_DataType = "Number",
						CBC_TriState = false,
						INP_Default = 1,
					},
					SeperaterButtonHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 1,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Seperator Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					SeperateStart_End = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "tool:SetInput('SeperaterButtonHider', 0)\ntool:SetInput('EndSeperatedHider', 1)\ntool.StartNumber:SetAttrs({INPS_Name = 'Start Number'})\ntool:SetInput('UndoSeperaterButtonHider', 1)\nlocal startEndNum = tool:GetInput('StartNumber')\ntool:SetInput('EndNumber', startEndNum)\ntool.Value:SetExpression('iif(time>InAnimLength+InAnimStart, EndNumber + (MasterAnim*(RestNumber-EndNumber)), StartNumber + (MasterAnim*(RestNumber-StartNumber)))')",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Seperate Start & End"
					},
					UndoSeperaterButtonHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 1,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Undo Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					UndoSeperation = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "tool:SetInput('SeperaterButtonHider', 1)\ntool:SetInput('EndSeperatedHider', 0)\ntool.StartNumber:SetAttrs({INPS_Name = 'Start & End Number'})\ntool:SetInput('UndoSeperaterButtonHider', 0)\ntool.Value:SetExpression('StartNumber + (MasterAnim*(RestNumber-StartNumber))')",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Undo Seperation"
					},
					StartNumber = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 5,
						INP_Default = 0,
						INP_MinScale = -5,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Start & End Number"
					},
					RestNumber = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 5,
						INP_Default = 0,
						INP_MinScale = -5,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Rest Number"
					},
					EndSeperatedHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 1,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "End Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					EndNumber = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 5,
						INP_Default = 0,
						INP_MinScale = -5,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "End Number"
					},
					Sep1 = {
						INP_External = false,
						INPID_InputControl = "SeparatorControl",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "",
					},
					AnimationControlsLabel = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						LBLC_NumInputs = 10,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "Animation Controls"
					},
					SecondsHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 7,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Seconds Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					ConverttoFrames = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "]].. uniqueName .. [[_CONTROLS.InAnimLength:SetExpression()\n]].. uniqueName .. [[_CONTROLS.OutAnimLength:SetExpression()\n]].. uniqueName .. [[_CONTROLS.InAnimStart:SetExpression()\n]].. uniqueName .. [[_CONTROLS.OutAnimEnd:SetExpression()\ntool:SetInput('FramesHider', 1)\ntool:SetInput('SecondsHider', 0)",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Convert to Frames"
					},
					InAnimLengthSeconds = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 25,
						INP_Default = 1,
						INP_MinScale = 0.00999999977648258,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "In Anim Length"
					},
					OutAnimLengthSeconds = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 25,
						INP_Default = 1,
						INP_MinScale = 0.00999999977648258,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Out Anim Length"
					},
					CalculatesfromCompStartLabel2 = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculates from Comp Start"
					},
					InAnimStartSeconds = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 25,
						INP_Default = 0,
						INP_MinScale = -25,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "In Anim Start"
					},
					CalculatesfromCompEndLabel2 = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculates from Comp End"
					},
					OutAnimEndSeconds = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 25,
						INP_Default = 0,
						INP_MinScale = -25,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Out Anim End"
					},
					FramesHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 7,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Frames Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					ConverttoSeconds = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "tool:SetInput('FramesHider', 0)\ntool:SetInput('SecondsHider', 1)\nfusion = Fusion(); fu = fusion; composition = fu.CurrentComp; comp = composition;\nlocal seconds1 = tool:GetInput('InAnimLength')/comp:GetPrefs('Comp.FrameFormat.Rate')\nlocal seconds2 = tool:GetInput('OutAnimLength')/comp:GetPrefs('Comp.FrameFormat.Rate')\ntool:SetInput('InAnimLengthSeconds', seconds1)\ntool:SetInput('OutAnimLengthSeconds', seconds2)\nlocal seconds3 = tool:GetInput('InAnimStart')/comp:GetPrefs('Comp.FrameFormat.Rate')\nlocal seconds4 = tool:GetInput('OutAnimEnd')/comp:GetPrefs('Comp.FrameFormat.Rate')\ntool:SetInput('InAnimStartSeconds', seconds3)\ntool:SetInput('OutAnimEndSeconds', seconds4)\n]].. uniqueName .. [[_CONTROLS.InAnimLength:SetExpression('InAnimLengthSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.OutAnimLength:SetExpression('OutAnimLengthSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.InAnimStart:SetExpression('InAnimStartSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.OutAnimEnd:SetExpression('OutAnimEndSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Convert to Seconds"
					},
					InAnimLength = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 50,
						INP_Default = 24,
						INP_MinScale = 1,
						INP_MinAllowed = 1,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "In Anim Length"
					},
					OutAnimLength = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 50,
						INP_Default = 24,
						INP_MinScale = 1,
						INP_MinAllowed = 1,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Out Anim Length"
					},
					CalculatesfromCompStartLabel = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculates from Comp Start"
					},
					InAnimStart = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 50,
						INP_Default = 0,
						INP_MinScale = -50,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "In Anim Start"
					},
					CalculatesfromCompEndLabel = {
						INP_MaxAllowed = 1000000,
						INP_Integer = false,
						LBLC_DropDownButton = false,
						INPID_InputControl = "LabelControl",
						INP_MaxScale = 1,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						INP_External = false,
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculates from Comp End"
					},
					OutAnimEnd = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "SliderControl",
						INP_MaxScale = 50,
						INP_Default = 0,
						INP_MinScale = -50,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Out Anim End"
					},
					CalcStartButtHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 1,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Calc Start Button Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					CalculatefromStart = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "tool:SetInput('CalcStartButtHider', 0)\ntool:SetInput('CalcEndButtHider', 1)\ntool.CalculatesfromCompEndLabel:SetAttrs({INPS_Name = 'Calculates from Comp Start'})\ntool.CalculatesfromCompEndLabel2:SetAttrs({INPS_Name = 'Calculates from Comp Start'})\ntool.OutAnimEnd:SetAttrs({INPS_Name = 'Out Anim Start'})\ntool.OutAnimEndSeconds:SetAttrs({INPS_Name = 'Out Anim Start'})\n]].. uniqueName .. [[_OUTCURVES.TimeOffset:SetExpression('(]].. uniqueName .. [[_CONTROLS.OutAnimEnd/(comp.RenderEnd-comp.RenderStart))')",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculate from Start"
					},
					CalcEndButtHider = {
						INP_Integer = true,
						LBLC_DropDownButton = true,
						INPID_InputControl = "LabelControl",
						LBLC_NumInputs = 1,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "Calc End Button Hider",
						INP_Passive = true,
						ICS_ControlPage = "Controls",
						IC_Visible = false,
					},
					CalculatefromEnd = {
						INP_MaxAllowed = 1000000,
						INP_Integer = true,
						INPID_InputControl = "ButtonControl",
						BTNCS_Execute = "tool:SetInput('CalcStartButtHider', 1)\ntool:SetInput('CalcEndButtHider', 0)\ntool.CalculatesfromCompEndLabel:SetAttrs({INPS_Name = 'Calculates from Comp End'})\ntool.CalculatesfromCompEndLabel2:SetAttrs({INPS_Name = 'Calculates from Comp End'})\ntool.OutAnimEnd:SetAttrs({INPS_Name = 'Out Anim End'})\ntool.OutAnimEndSeconds:SetAttrs({INPS_Name = 'Out Anim End'})\n]].. uniqueName .. [[_OUTCURVES.TimeOffset:SetExpression('1-((]].. uniqueName .. [[_CONTROLS.OutAnimLength+]].. uniqueName .. [[_CONTROLS.OutAnimEnd)/(comp.RenderEnd-comp.RenderStart))')",
						INP_MaxScale = 1,
						INP_Default = 0,
						INP_MinScale = 0,
						INP_MinAllowed = -1000000,
						LINKID_DataType = "Number",
						ICS_ControlPage = "Controls",
						LINKS_Name = "Calculate from End"
					}
				}
			}
		},
				ActiveTool = "]] .. uniqueName .. [[_VALUE"
			}
]]
return s
end
-- Anim Utility Modifiers for Sliders
local function animUtilityNumber(uniqueName, ControlVal)
	ControlVal = ControlVal or 0
    local s = [[
		{
			Tools = ordered() {]]
				.. uniqueName .. [[_CONNECT_TO_ME = Calculation {
					NameSet = true,
					Inputs = {
						CONNECTION = Input {
							SourceOp = "]].. uniqueName .. [[_CONTROLS",
							Source = "Value",
						}
					},
					UserControls = ordered() {
						CONNECTION = {
							INP_Integer = false,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Calc",
							INPID_InputControl = "SliderControl",
							LINKS_Name = "CONNECTION",
						}
					}
				},]]
				.. uniqueName .. [[_INCURVES = LUTLookup {
					NameSet = true,
					Inputs = {
						Curve = Input { Value = FuID { "Easing" }, },
						EaseIn = Input { Value = FuID { "Sine" }, },
						EaseOut = Input { Value = FuID { "Quad" }, },
						Lookup = Input {
							SourceOp = "]].. uniqueName .. [[_INCURVESLookup",
							Source = "Value",
						},
						Source = Input { Value = FuID { "Duration" }, },
						Scaling = Input { Value = 0, },
						Scale = Input { Expression = "iif(]].. uniqueName .. [[_CONTROLS.In == 1, 1, 0)", },
						Offset = Input { Expression = "iif(]].. uniqueName .. [[_CONTROLS.In == 1, 0, 1)", },
						Timing = Input { Value = 0, },
						TimeScale = Input {
							Value = 4.95833333333333,
							Expression = "(comp.RenderEnd-comp.RenderStart)/]].. uniqueName .. [[_CONTROLS.InAnimLength",
						},
						TimeOffset = Input { Expression = "]].. uniqueName .. [[_CONTROLS.InAnimStart/(comp.RenderEnd-comp.RenderStart)", }
					},
					UserControls = ordered() {
					AnimUtilityLogo = {
						INP_Integer = false,
						INPID_InputControl = "LabelControl",
						IC_ControlPage = -1,
						LBLC_MultiLine = true,
						INP_External = false,
						LINKID_DataType = "Number",
						LINKS_Name = "<center><img src='data:image/png;base64,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> ",
						INP_Passive = true,
						IC_NoLabel = true,
						IC_NoReset = true,
					},
						HiddenControls = {
							INP_Integer = false,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 14,
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
							LINKS_Name = "Curve Shape"
						},
						Source = {
							ICS_ControlPage = "Controls",
							INP_Integer = false,
							LINKID_DataType = "Number",
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
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
						},
						Curve = {
							LINKS_Name = "Curve",
							LINKID_DataType = "Number",
							INP_Integer = false,
							ICS_ControlPage = "Controls",
						},
						Lookup = {
							LINKS_Name = "Lookup",
							LINKID_DataType = "Number",
							INP_Integer = false,
							ICS_ControlPage = "Controls",
						}
					}
				},]]
				.. uniqueName .. [[_INCURVESLookup = LUTBezier {
					KeyColorSplines = {
						[0] = {
							[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },
							[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }
						}
					},
					SplineColor = { Red = 255, Green = 255, Blue = 255 },
				},
				]].. uniqueName .. [[_OUTCURVES = LUTLookup {
					NameSet = true,
					Inputs = {
						Curve = Input { Value = FuID { "Easing" }, },
						EaseIn = Input { Value = FuID { "Quad" }, },
						EaseOut = Input { Value = FuID { "Sine" }, },
						Lookup = Input {
							SourceOp = "]].. uniqueName .. [[_OUTCURVESLookup",
							Source = "Value",
						},
						Source = Input { Value = FuID { "Duration" }, },
						Scale = Input {
							Value = -1,
							Expression = "iif(]].. uniqueName .. [[_CONTROLS.Out == 1, -1, 0)",
						},
						TimeScale = Input {
							Value = 4.95833333333333,
							Expression = "(comp.RenderEnd-comp.RenderStart)/]].. uniqueName .. [[_CONTROLS.OutAnimLength",
						},
						TimeOffset = Input {
							Value = 0.798319327731092,
							Expression = "1-((]].. uniqueName .. [[_CONTROLS.OutAnimLength+]].. uniqueName .. [[_CONTROLS.OutAnimEnd)/(comp.RenderEnd-comp.RenderStart))",
						}
					},
					UserControls = ordered() {
						AnimUtilityLogo = {
							INP_Integer = false,
							INPID_InputControl = "LabelControl",
							IC_ControlPage = -1,
							LBLC_MultiLine = true,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "<center><img src='data:image/png;base64,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> ",
							INP_Passive = true,
							IC_NoLabel = true,
							IC_NoReset = true,
						},
						HiddenControls = {
							INP_Integer = false,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 14,
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
							LINKS_Name = "Curve Shape"
						},
						Source = {
							ICS_ControlPage = "Controls",
							INP_Integer = false,
							LINKID_DataType = "Number",
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
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
							ICS_ControlPage = "Controls",
							INP_MaxScale = 1,
							INP_Default = 1,
							INP_MinScale = 0,
							INP_MinAllowed = 0,
							LINKID_DataType = "Number",
							INP_Passive = true,
							INP_External = false,
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
						},
						Curve = {
							LINKS_Name = "Curve",
							LINKID_DataType = "Number",
							INP_Integer = false,
							ICS_ControlPage = "Controls",
						},
						Lookup = {
							LINKS_Name = "Lookup",
							LINKID_DataType = "Number",
							INP_Integer = false,
							ICS_ControlPage = "Controls",
						}
					}
				},
				]].. uniqueName .. [[_OUTCURVESLookup = LUTBezier {
					KeyColorSplines = {
						[0] = {
							[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },
							[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }
						}
					},
					SplineColor = { Red = 255, Green = 255, Blue = 255 },
				},
				]].. uniqueName .. [[_CONTROLS = PublishNumber {
					CtrlWZoom = false,
					NameSet = true,
					Inputs = {
						CommentsNest = Input { Value = 0, },
						FrameRenderScriptNest = Input { Value = 0, },
						Value = Input { Expression = "StartNumber + (MasterAnim*(RestNumber-StartNumber))", },
						InCurves = Input {
							SourceOp = "]].. uniqueName .. [[_INCURVES",
							Source = "Value",
						},
						OutCurves = Input {
							SourceOp = "]].. uniqueName .. [[_OUTCURVES",
							Source = "Value",
						},
						MasterAnim = Input {
							Value = 1,
							Expression = "InCurves+OutCurves",
						},
						Start_EndSeperatedHider = Input { Value = 1, },
						SeperaterButtonHider = Input { Value = 1, },
						FramesHider = Input { Value = 1, },
						CalcsEndHider1 = Input { Value = 1, },
						CalcsEndHider2 = Input { Value = 1, },
						CalcStartButtHider = Input { Value = 1, },
						USERLabel = Input { Value = 1, },
						AnimationControlsLabel = Input { Value = 1, },
						StartNumber = Input { Value = 0, },
						RestNumber = Input{ Value = ]] .. ControlVal .. [[, },
					},
					UserControls = ordered() {
						Value = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "ScrewControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Common",
							LINKS_Name = "Value"
						},
						InCurves = {
							INP_Integer = false,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Common",
							INPID_InputControl = "ScrewControl",
							LINKS_Name = "InCurves",
						},
						OutCurves = {
							INP_Integer = false,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Common",
							INPID_InputControl = "ScrewControl",
							LINKS_Name = "OutCurves",
						},
						MasterAnim = {
							INP_Integer = false,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Common",
							INPID_InputControl = "ScrewControl",
							LINKS_Name = "MasterAnim",
						},
						AnimUtilityLogo = {
							INP_Integer = false,
							INPID_InputControl = "LabelControl",
							IC_ControlPage = -1,
							LBLC_MultiLine = true,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "<center><img src='data:image/png;base64,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> ",
							INP_Passive = true,
							IC_NoLabel = true,
							IC_NoReset = true,
						},
						USERLabel = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							LBLC_NumInputs = 13,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "]] .. uniqueName .. [[ Controls"
						},
						In = {
							ICD_Width = 0.5,
							INP_Integer = true,
							LINKS_Name = "In",
							ICS_ControlPage = "Controls",
							INPID_InputControl = "CheckboxControl",
							LINKID_DataType = "Number",
							CBC_TriState = false,
							INP_Default = 1,
						},
						Out = {
							ICD_Width = 0.5,
							INP_Integer = true,
							LINKS_Name = "Out",
							ICS_ControlPage = "Controls",
							INPID_InputControl = "CheckboxControl",
							LINKID_DataType = "Number",
							CBC_TriState = false,
							INP_Default = 1,
						},
						SeperaterButtonHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 1,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Seperator Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						SeperateStart_End = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "tool:SetInput('SeperaterButtonHider', 0)\ntool:SetInput('EndSeperatedHider', 1)\ntool.StartNumber:SetAttrs({INPS_Name = 'Start Number'})\ntool:SetInput('UndoSeperaterButtonHider', 1)\nlocal startEndNum = tool:GetInput('StartNumber')\ntool:SetInput('EndNumber', startEndNum)\ntool.Value:SetExpression('iif(time>InAnimLength+InAnimStart, EndNumber + (MasterAnim*(RestNumber-EndNumber)), StartNumber + (MasterAnim*(RestNumber-StartNumber)))')",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Seperate Start & End"
						},
						UndoSeperaterButtonHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 1,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Undo Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						UndoSeperation = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "tool:SetInput('SeperaterButtonHider', 1)\ntool:SetInput('EndSeperatedHider', 0)\ntool.StartNumber:SetAttrs({INPS_Name = 'Start & End Number'})\ntool:SetInput('UndoSeperaterButtonHider', 0)\ntool.Value:SetExpression('StartNumber + (MasterAnim*(RestNumber-StartNumber))')",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Undo Seperation"
						},
						StartNumber = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 5,
							INP_Default = 0,
							INP_MinScale = -5,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Start & End Number"
						},
						RestNumber = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 5,
							INP_Default = 0,
							INP_MinScale = -5,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Rest Number"
						},
						EndSeperatedHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 1,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "End Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						EndNumber = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 5,
							INP_Default = 0,
							INP_MinScale = -5,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "End Number"
						},
						Sep1 = {
							INP_External = false,
							INPID_InputControl = "SeparatorControl",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "",
						},
						AnimationControlsLabel = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							LBLC_NumInputs = 10,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "Animation Controls"
						},
						SecondsHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 7,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Seconds Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						ConverttoFrames = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "]].. uniqueName .. [[_CONTROLS.InAnimLength:SetExpression()\n]].. uniqueName .. [[_CONTROLS.OutAnimLength:SetExpression()\n]].. uniqueName .. [[_CONTROLS.InAnimStart:SetExpression()\n]].. uniqueName .. [[_CONTROLS.OutAnimEnd:SetExpression()\ntool:SetInput('FramesHider', 1)\ntool:SetInput('SecondsHider', 0)",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Convert to Frames"
						},
						InAnimLengthSeconds = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 25,
							INP_Default = 1,
							INP_MinScale = 0.00999999977648258,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "In Anim Length"
						},
						OutAnimLengthSeconds = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 25,
							INP_Default = 1,
							INP_MinScale = 0.00999999977648258,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Out Anim Length"
						},
						CalculatesfromCompStartLabel2 = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculates from Comp Start"
						},
						InAnimStartSeconds = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 25,
							INP_Default = 0,
							INP_MinScale = -25,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "In Anim Start"
						},
						CalculatesfromCompEndLabel2 = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculates from Comp End"
						},
						OutAnimEndSeconds = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 25,
							INP_Default = 0,
							INP_MinScale = -25,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Out Anim End"
						},
						FramesHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 7,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Frames Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						ConverttoSeconds = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "tool:SetInput('FramesHider', 0)\ntool:SetInput('SecondsHider', 1)\nfusion = Fusion(); fu = fusion; composition = fu.CurrentComp; comp = composition;\nlocal seconds1 = tool:GetInput('InAnimLength')/comp:GetPrefs('Comp.FrameFormat.Rate')\nlocal seconds2 = tool:GetInput('OutAnimLength')/comp:GetPrefs('Comp.FrameFormat.Rate')\ntool:SetInput('InAnimLengthSeconds', seconds1)\ntool:SetInput('OutAnimLengthSeconds', seconds2)\nlocal seconds3 = tool:GetInput('InAnimStart')/comp:GetPrefs('Comp.FrameFormat.Rate')\nlocal seconds4 = tool:GetInput('OutAnimEnd')/comp:GetPrefs('Comp.FrameFormat.Rate')\ntool:SetInput('InAnimStartSeconds', seconds3)\ntool:SetInput('OutAnimEndSeconds', seconds4)\n]].. uniqueName .. [[_CONTROLS.InAnimLength:SetExpression('InAnimLengthSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.OutAnimLength:SetExpression('OutAnimLengthSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.InAnimStart:SetExpression('InAnimStartSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')\n]].. uniqueName .. [[_CONTROLS.OutAnimEnd:SetExpression('OutAnimEndSeconds*comp:GetPrefs(\"Comp.FrameFormat.Rate\")')",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Convert to Seconds"
						},
						InAnimLength = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 50,
							INP_Default = 24,
							INP_MinScale = 1,
							INP_MinAllowed = 1,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "In Anim Length"
						},
						OutAnimLength = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 50,
							INP_Default = 24,
							INP_MinScale = 1,
							INP_MinAllowed = 1,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Out Anim Length"
						},
						CalculatesfromCompStartLabel = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculates from Comp Start"
						},
						InAnimStart = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 50,
							INP_Default = 0,
							INP_MinScale = -50,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "In Anim Start"
						},
						CalculatesfromCompEndLabel = {
							INP_MaxAllowed = 1000000,
							INP_Integer = false,
							LBLC_DropDownButton = false,
							INPID_InputControl = "LabelControl",
							INP_MaxScale = 1,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							INP_External = false,
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculates from Comp End"
						},
						OutAnimEnd = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "SliderControl",
							INP_MaxScale = 50,
							INP_Default = 0,
							INP_MinScale = -50,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Out Anim End"
						},
						CalcStartButtHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 1,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Calc Start Button Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						CalculatefromStart = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "tool:SetInput('CalcStartButtHider', 0)\ntool:SetInput('CalcEndButtHider', 1)\ntool.CalculatesfromCompEndLabel:SetAttrs({INPS_Name = 'Calculates from Comp Start'})\ntool.CalculatesfromCompEndLabel2:SetAttrs({INPS_Name = 'Calculates from Comp Start'})\ntool.OutAnimEnd:SetAttrs({INPS_Name = 'Out Anim Start'})\ntool.OutAnimEndSeconds:SetAttrs({INPS_Name = 'Out Anim Start'})\n]].. uniqueName .. [[_OUTCURVES.TimeOffset:SetExpression('(]].. uniqueName .. [[_CONTROLS.OutAnimEnd/(comp.RenderEnd-comp.RenderStart))')",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculate from Start"
						},
						CalcEndButtHider = {
							INP_Integer = true,
							LBLC_DropDownButton = true,
							INPID_InputControl = "LabelControl",
							LBLC_NumInputs = 1,
							INP_External = false,
							LINKID_DataType = "Number",
							LINKS_Name = "Calc End Button Hider",
							INP_Passive = true,
							ICS_ControlPage = "Controls",
							IC_Visible = false,
						},
						CalculatefromEnd = {
							INP_MaxAllowed = 1000000,
							INP_Integer = true,
							INPID_InputControl = "ButtonControl",
							BTNCS_Execute = "tool:SetInput('CalcStartButtHider', 1)\ntool:SetInput('CalcEndButtHider', 0)\ntool.CalculatesfromCompEndLabel:SetAttrs({INPS_Name = 'Calculates from Comp End'})\ntool.CalculatesfromCompEndLabel2:SetAttrs({INPS_Name = 'Calculates from Comp End'})\ntool.OutAnimEnd:SetAttrs({INPS_Name = 'Out Anim End'})\ntool.OutAnimEndSeconds:SetAttrs({INPS_Name = 'Out Anim End'})\n]].. uniqueName .. [[_OUTCURVES.TimeOffset:SetExpression('1-((]].. uniqueName .. [[_CONTROLS.OutAnimLength+]].. uniqueName .. [[_CONTROLS.OutAnimEnd)/(comp.RenderEnd-comp.RenderStart))')",
							INP_MaxScale = 1,
							INP_Default = 0,
							INP_MinScale = 0,
							INP_MinAllowed = -1000000,
							LINKID_DataType = "Number",
							ICS_ControlPage = "Controls",
							LINKS_Name = "Calculate from End"
						}
					}
				}
			},
			ActiveTool = "]].. uniqueName .. [[_CONNECT_TO_ME"
		}
		]]
    return s
end

local function CreateToolWindow()
	local mainWnd = disp:AddWindow(
	{
		ID = "MainWindow",
		WindowTitle = "Anim Utility | " .. nodeName,
		Geometry = { AnimUtility_HVpos_x,AnimUtility_HVpos_y,width,height },
		Spacing = 0,
		ui:VGroup{
		ui:VGroup{
                    Weight = 0,
                    ID = "install_bar",
                    Spacing = 0
                },
		ui:VGroup{
            ID = "root",
			ui:Button{ID = 'AnimUtilityIconButt', Weight = 0, IconSize = {width - 100, 45}, Icon = ui:Icon{File = icons .. "Logo.png"}, Flat = true, MaximumSize = { width, 45 }, MinimumSize = { width, 45 },},
            ui:HGroup{
				Weight = 0.02,
				MinimumSize = {width, 10},
                ui:Label{ID = 'ControlsLabel', Text = 'Node Controls (Click a Control to Select)', Weight = 0.0005, MaximumSize = { width-95, 24 }, MinimumSize = { width-95, 24 }, StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);font-weight: bold;]]},
				ui:Button{ID = 'Reload', Text = '↺', Weight = 0.001, ToolTip = "Reload Controls List",Font = ui:Font{PixelSize = 25,},Flat = true, MaximumSize = { width-280, 24 }, MinimumSize = { width-280, 24 }, StyleSheet = [[font-family: Amaranth;color:rgb(255,255,255);]]}
			},
			ui:VGroup{
				Weight = 0.5,
				MinimumSize = {width, 100},
				ui:LineEdit{ID = 'SearchBar', PlaceholderText = 'Enter Control ID to Search',Weight = 0.01, MaximumSize = { width, 24 }, MinimumSize = { width, 24 }, StyleSheet = [[font-family: Amaranth;font-size: 15px;]]},
                ui:Tree{ID = 'NodeControls', Events = { ItemClicked = true }, Weight = 0.25, MaximumSize = { width, 200 }, MinimumSize = { width, 200 }, StyleSheet = [[background-color:#1f1f1f;font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);]]},
				ui:Label{Weight = 0, MaximumSize = { width, 8 }, MinimumSize = { width, 8 } },
				ui:Label{ID = 'UniqueNameLabel', Text = 'Unique Name for Anim Utility Modifiers', Weight = 0.01, MaximumSize = { width, 18 }, MinimumSize = { width, 18 }, StyleSheet = [[font-family: Amaranth;font-size: 15px;font-weight: bold;color:rgb(255,255,255);]]},
                ui:LineEdit{ ID = 'UniqueName', PlaceholderText = 'Unique Name', Weight = 0.03, MaximumSize = { width, 34 }, MinimumSize = { width, 34 }, StyleSheet = [[font-family: Amaranth;font-size: 15px;]]},
                ui:Button{ID = 'Paste', Text = 'Paste Anim Utility', Weight = 0.02, MaximumSize = { width, 34 }, MinimumSize = { width, 34 }, StyleSheet = [[QPushButton{border: 1px solid rgb(164,66,41);max-height: 28px;border-radius: 14px;background-color: rgb(164,66,41);color: rgb(220, 220, 220);min-height: 28px;font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);}QPushButton:hover{border: 2px solid rgb(235,152,79);background-color: rgb(235,152,79);}]]},
				ui:Label{Weight = 0, FrameStyle = 4, MaximumSize = { width, 2 }, MinimumSize = { width, 2 } },
            },
			ui:HGroup{
				Weight = 0.02,
				MinimumSize = {width, 25},
				MaximumSize = { width, 25 },
				ui:Button{ID = 'YT', MaximumSize = { width-340, 25 }, MinimumSize = { width-340, 25 }, IconSize = {width-300,25}, Icon = ui:Icon{File = icons .. 'YouTube.png'}, Flat = true, ToolTip = "YouTube Tutorial",StyleSheet = [[font-family: Amaranth;]]},
				ui:Button{ID = 'KoFi', MaximumSize = { width-340, 25 }, MinimumSize = { width-340, 25 }, IconSize = {width-325,25}, Icon = ui:Icon{File = icons .. 'KoFi.png'}, Flat = true, ToolTip = "More Fusion Goodies",StyleSheet = [[font-family: Amaranth;]]}
			}
        },
	}
    }
)
mainWnditm = mainWnd:GetItems()

function mainWnd.On.MainWindow.Close(ev)
	fusion:SetData("AnimUtility_HVpos", mainWnditm.MainWindow.Geometry) -- Sets Current Poistion to New Position for Next Open
	disp:ExitLoop()
end

function mainWnd.On.YT.Clicked(ev)
	bmd.openurl('https://youtu.be/XR1yyT2SsGk')
end

function mainWnd.On.KoFi.Clicked(ev)
	bmd.openurl('https://www.ko-fi.com/asherroland')
end

function mainWnd.On.AnimUtilityIconButt.Clicked(ev)
	bmd.openurl('https://www.fusionpixelstudio.com')
end
-- Prevents user from typing characters that will cause pasting errors
function mainWnd.On.UniqueName.TextChanged(ev)
	local txt = ev.Text
	if string.find(txt, " ") then
		mainWnditm.UniqueName.Text = string.gsub(txt, " ", "_")
	end
	if string.find(txt, "/") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "/", "_")
	end
	if string.find(txt, "\\") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "\\", "_")
	end
	if string.find(txt, "-") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "-", "_")
	end
	if string.find(txt, "%(") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "%(", "_")
	end
	if string.find(txt, "%)") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "%)", "_")
	end
	if string.find(txt, "~") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "~", "_")
	end
	if string.find(txt, "%.") then
		mainWnditm.UniqueName.Text = string.gsub(txt, "%.", "_")
	end
end

function BuildSearchKey(t, key)
	if type(t) == "string" or type(t) == "number" then
		key[#key+1] = tostring(t):lower()
	elseif type(t) == "table" then
		for i,v in pairs(t) do
			BuildSearchKey(v, key)
		end
	end
end

local control_type

local function fillTree()
	comp:SetData("tool_control_pages", {})
	local tool_control_pages = comp:GetData("tool_control_pages")
	NodeControls = {}
	local tool = comp.ActiveTool
    local x = tool:GetInputList(Number)
	mainWnditm.NodeControls:Clear()
    for _, v in ipairs(x) do
		control_type = v:GetAttrs().INPS_DataType
        local control = v:GetAttrs().INPS_ID 
		local controlName = v:GetAttrs().INPS_Name
		Controls = {}
		Controls.ID = control
		Controls.Name = controlName
		Controls.Type = control_type
		table.insert(NodeControls, Controls)
    end
	for _, c in ipairs(NodeControls) do
		local it = mainWnditm.NodeControls:NewItem()
		if c.Type == "Number" or c.Type == "Point" then
			it.Text[0] = c.ID
			it.Text[1] = c.Name
			it.Text[2] = c.Type
			mainWnditm.NodeControls:AddTopLevelItem(it)
		end
		c._TreeItem = it
		c._Hidden = false
	end
	comp:SetData("tool_control_pages", tool_control_pages)
	for i,v in ipairs(NodeControls) do

		local searchkey = {}

		BuildSearchKey(v, searchkey)

		v._SearchKey = table.concat(searchkey, "\n")
	end
end

local function sortTable()
	mainWnditm.NodeControls.UpdatesEnabled = false
	mainWnditm.NodeControls.SortingEnabled = false
	local key = g_FilterText:lower()
    for _, v in pairs(NodeControls) do
		local hide = true
		if #key == 0 or v._SearchKey:match(key) then -- Checks what is typed in Search bar with what is in the Table
			hide = false
		end
		if hide ~= v.Hidden then
			v.Hidden = hide
			v._TreeItem.Hidden = hide
		end
	end
	mainWnditm.NodeControls.UpdatesEnabled = true
	mainWnditm.NodeControls.SortingEnabled = true
end

function mainWnd.On.SearchBar.TextChanged(ev)
	g_FilterText = ev.Text
	sortTable(mainWnditm.NodeControls)
end

local Control
nodeName = node:GetAttrs().TOOLS_Name
local controlType
-- Collects what Controls was selected and Creates a template unique name
function mainWnd.On.NodeControls.ItemClicked(ev)
	node = comp.ActiveTool
	if node == nil then
		showMessage(425,"No Selected Node","Please make sure you have a node selected while using this tool!") --You must have a node to select a control
	else
		ControlVal = nil
		Control = ev.item.Text[0]
		controlType = ev.item.Text[2]
		ControlVal = node:GetInput(tostring(Control))
		mainWnditm.UniqueName:Clear()
		nodeName = node:GetAttrs().TOOLS_Name
		mainWnditm.UniqueName.Text = tostring(nodeName) .. '_' .. tostring(Control)
	end
end

local hdr2 = mainWnditm.NodeControls:NewItem()
hdr2.Text[0] = 'Control IDs'
hdr2.Text[1] = 'Control Names'
mainWnditm.NodeControls:SetHeaderItem(hdr2)
mainWnditm.NodeControls.ColumnCount = 2
mainWnditm.NodeControls.ColumnWidth[0] = 200
-- Resets GUI and gets controls for currently selected node
function mainWnd.On.Reload.Clicked(ev)
	node = comp.ActiveTool
	if node == nil then
		showMessage(425,"No Selected Node","No Node Selected!\nPlease select a node before Reloading!")
	else
		nodeName = node:GetAttrs().TOOLS_Name
		mainWnditm.SearchBar:Clear()
		mainWnditm.NodeControls:Clear()
		mainWnditm.UniqueName:Clear()
		mainWnditm.MainWindow.WindowTitle = "Anim Utility | " .. nodeName
		fillTree()
		Control = nil
		controlType = nil
	end
end
-- Gathers the Modifiers for the selected control's type, pastes them and connects the chosen control to the modifier's connector
function mainWnd.On.Paste.Clicked(ev)
	fusion:SetData("AnimUtility_HVpos", mainWnditm.MainWindow.Geometry)
    local name = (tostring(mainWnditm.UniqueName.Text))
	node = comp.ActiveTool
	nodeName = node:GetAttrs().TOOLS_Name
    if name == '' then
        showMessage(425,"No Unique Name","Please Write Out a Unique Name.")
    else
			if controlType == 'Number' then
				comp:Paste(bmd.readstring(animUtilityNumber(name,ControlVal)))
				local nodeControl = tostring(nodeName) .. '.' .. tostring(Control)
				local Modifierstr = name .. '_CONNECT_TO_ME.CONNECTION'
		if Control ~= nil then
			comp:Execute(nodeControl .. ":ConnectTo(" .. Modifierstr .. ")")
		end
		mainWnditm.Paste.Text = "Success!"
		bmd.wait(5)
		mainWnditm.Paste.Text = "Paste Anim Utility"
	elseif controlType == 'Point' then
		
		comp:Paste(bmd.readstring(animUtilityPoint(name,ControlVal[1]..','..ControlVal[2])))
		local nodeControl = tostring(nodeName) .. '.' .. tostring(Control)
		local Modifierstr = name .. '_VECTOR.Position'
		if Control ~= nil then
			comp:Execute(nodeControl .. ":ConnectTo(" .. Modifierstr .. ")")
		end
		mainWnditm.Paste.Text = "Success!"
		bmd.wait(5)
		mainWnditm.Paste.Text = "Paste Anim Utility"
	else 
		comp:Paste(bmd.readstring(animUtilityNumber(name)))
		local nodeControl = tostring(nodeName) .. '.' .. tostring(Control)
		local Modifierstr = name .. '_CONNECT_TO_ME.CONNECTION'
		if Control ~= nil then
			comp:Execute(nodeControl .. ":ConnectTo(" .. Modifierstr .. ")")
		end
		showMessage(410,"Pasted Succesfully","Pasted " .. name .. " Anim Utility.\nYou did not select a control.\nPlease do 'Connect To' on the control you want to animate and connect to " .. Modifierstr..".")
	end
    end
end

function mainWnd.On.install.Clicked(ev)
	local success = InstallScript()
	if not success then
		return
	end

	local content = mainWnd:GetItems().install_bar
	content:RemoveChild("install_group")
	mainWnd:RecalcLayout()
end
-- If script is in the wrong place, show install Bar
	if not SCRIPT_INSTALLED then
		local content = mainWnd:GetItems().install_bar
		content:AddChild(
			ui:VGroup
			{
				ID = "install_group",
				Weight = 0,
				Spacing = 3,
				StyleSheet = [[
					QWidget
					{
						margin-bottom: 0px;
					}
				]],
				ui:HGroup{
					ui:Label{
						Weight = 0.45,
						Text = "Install tool to Resolve's Scripts folder?"
					},
					ui:Button{
						Weight = 0.30,
						ID = "install",
						Text = "Install",
					}
				},
				ui:Label{
					Weight = 0,
					FrameStyle = 4,
				}
			})
	end

    fillTree()
	mainWnd:RecalcLayout()
    mainWnd:Show()
    disp:RunLoop()
    mainWnd:Hide()
	print("Bye!")
end
-- You MUST have a node selected to open the GUI
if type(node) ~= "userdata" then
    showMessage(425,"No Selected Node","NO NODE SELECTED\nPlease Select a Node Before Activating Script.")
else
	node = comp.ActiveTool
	nodeName = node:GetAttrs().TOOLS_Name
	CreateToolWindow()
end

collectgarbage()