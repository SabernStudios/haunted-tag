local HighlightManager = {}

function HighlightManager.AddFadingHighlight(object, fadeTime)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.7
	highlight.Parent = object
	highlight.OutlineTransparency = 0.7
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	
	local fillTween = tweenService:Create(highlight, tweenInfo, {FillTransparency = 1})
	local outlineTween = tweenService:Create(highlight, tweenInfo, {OutlineTransparency = 1})
	
	fillTween:Play()
	outlineTween:Play()
	
	game.Debris:AddItem(highlight, fadeTime)
end

return HighlightManager
