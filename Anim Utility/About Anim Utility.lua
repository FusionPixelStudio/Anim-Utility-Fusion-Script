local icons = comp:MapPath('Scripts:/Comp/FusionPixelStudio/Anim Utility/files/')

_VERSION = [[Version 1 - Feburary 2024]]

ui = app.UIManager
disp = bmd.UIDispatcher(ui)
local originX, originY, width, height = 200, 200, 546, 308

	-- Create the new UI Manager Window
	local win = disp:AddWindow({
		ID = "AboutAnimUtilityWin",
		TargetID = "AboutAnimUtilityWin",
		WindowTitle = "About Anim Utility",
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = true,
		},
		Geometry = {
			originX,
			originY,
			width,
			height,
		},

		ui:VGroup {
			ID = "root",

			ui:HGroup{
				Weight = 0,
				ui:VGroup {
					Weight = 1,

					ui:Button{
						ID = 'FusionPixelButton',
						Weight = 0,
						IconSize = {68,68},
						Icon = ui:Icon{
							File = icons .. 'FusionPixel.png'
						},
						MinimumSize = {
							68,
							68,
						},
						Flat = true,
					},

					ui:Label {
						ID = "AnimUtilityLabel",
						Weight = 0,

						Text = "Anim Utility",
						ReadOnly = true,
						Alignment = {
							AlignHCenter = true,
							AlignVCenter = true,
						},
						Font = ui:Font{
							PixelSize = 36,
						},
						StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);]]
					},

					ui:Label {
						ID = "VersionLabel",
						Weight = 1,

						Text = _VERSION,
						WordWrap = true,
						Alignment = {
							AlignHCenter = true,
							AlignVCenter = true,
						},
						Font = ui:Font{
							PixelSize = 12,
						},
						StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);]]
					},

				},
			},

			ui:VGroup{
				ui:Label {
					ID = "AboutLabel",
					Text = [[Anim Utility is a tool for the Fusion page of Davinci Resolve that allows animations without keyframes and that are easy to customize! Which means this animation engine is great for creating your own Macros and Edit Page Effects! The GUI lets you select what node control you want to connect the animation engine to and make a custom name to make use of them way easier!]],
					OpenExternalLinks = true,
					WordWrap = true,
					Alignment = {
						AlignHCenter = true,
						AlignVCenter = true,
					},
					Font = ui:Font{
						PixelSize = 14,
					},
					StyleSheet = [[font-family: Amaranth;font-size: 15px;color:rgb(255,255,255);]]
				},

			},
		},
	})


	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The window was closed
	function win.On.AboutAnimUtilityWin.Close(ev)
		disp:ExitLoop()
	end

	-- Open the We Suck Less webpage when the Reactor logo is clicked
	function win.On.FusionPixelButton.Clicked(ev)
		bmd.openurl("https://www.youtube.com/channel/UC_OnaF0lKfexzEL9Yminymw")
		disp:ExitLoop()
	end

    win:Show()
	disp:RunLoop()
	win:Hide()