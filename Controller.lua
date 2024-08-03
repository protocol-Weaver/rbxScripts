repeat task.wait()

until game:IsLoaded()
local storage = game:GetService("ReplicatedStorage")

local TextureID = {
	"rbxassetid://18357231142",
	"rbxassetid://18357230843",
	"rbxassetid://18356887208",
	"rbxassetid://18356887551",
	"rbxassetid://18356888133",
	
}




local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

local storage = game:GetService("ReplicatedStorage")
local dash = storage.Dash

-- Create a new "Animation" instance and assign an animation asset ID
local kickAnimation = Instance.new("Animation")
kickAnimation.AnimationId = "rbxassetid://18314102259"

-- Load the animation onto the animator
local kickAnimationTrack = humanoid:LoadAnimation(kickAnimation)

local function SetVectorToSpecialMesh(SpecialMesh, Size)
	local Part = SpecialMesh.Parent
	local OriginalSize = Part.Size / SpecialMesh.Scale
	Part.Size = Size
	SpecialMesh.Scale = Size / OriginalSize
end

local function SlashInit()
	local sword = game:GetService("StarterPack").Tool
	local SlashMesh = storage.Slash:Clone()
	local VertexColor = Vector3.new(10,0,0)
	local Size = Vector3.new(13,1,12)
	local CFrameVal = CFrame.new(0,0,0)
	local StartRotation = CFrame.Angles(0,0,0)
	local RotationAmount = CFrame.Angles(0, -90, -90)
	local Time = 0.05
	local Parent = workspace
	local TweenRotationInfo = TweenInfo.new(0.3)
	local TweenRotationalGoal = {Value = RotationAmount}
	local AnimationImages = {
		"rbxassetid://18357231142",
		"rbxassetid://18357230843",
		"rbxassetid://18356887208",
		"rbxassetid://18356887551",
		
	}
	SetVectorToSpecialMesh(SlashMesh.Mesh, Size)
	SlashMesh.CFrame = CFrameVal
	SlashMesh.Mesh.VertexColor = VertexColor
	SlashMesh.Parent = Parent
	
	local RotationValue = Instance.new("CFrameValue")
	TweenService:Create(RotationValue, TweenRotationInfo, TweenRotationalGoal):Play()
	local MoveConnection = game:GetService("RunService").RenderStepped:Connect(function()
		SlashMesh.CFrame = character:GetPivot() * StartRotation * RotationValue.Value
	end)
	task.spawn(function()
		for _i , textures in pairs(AnimationImages) do 
			SlashMesh.Mesh.TextureId = textures	
			task.wait(Time)
		end
		MoveConnection:Disconnect()
		RotationValue:Destroy()
		SlashMesh:Destroy()
	end)
end


local function Slash()
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://18419828546"
	local Track = humanoid.Animator:LoadAnimation(Animation)
	Track:Play()
	Track.Stopped:Wait()
	SlashInit()
end


local function FireBall()
	
	local SlashMesh = storage.FireBall:Clone()
	local Time = 0.05
	local Parent = workspace
	SlashMesh.Parent = Parent
	SlashMesh.CFrame = character:GetPivot()
	local AnimationImages = {
		"rbxassetid://18530992981",
		"rbxassetid://18530992583",
		"rbxassetid://18530991751",
		"rbxassetid://18530991216",
		"rbxassetid://18530990616"
	}
	task.spawn(function()
		while true do
		for _i , textures in pairs(AnimationImages) do 
			SlashMesh.Mesh.TextureId = textures	
			task.wait(Time)
			end 
		end
		--SlashMesh:Destroy()
	end)
end

local function TrailConnector()
	local trailAttachment0 = Instance.new("Attachment")
	trailAttachment0.Name = "TrailAttachment0"
	trailAttachment0.Parent = humanoidRootPart
	
	local trailAttachment1 = Instance.new("Attachment")
	trailAttachment1.Name = "TrailAttachment1"
	trailAttachment1.Position = trailAttachment0.Position + Vector3.new(0,1.5,0)
	trailAttachment1.Parent = humanoidRootPart
end

local function Dash()
	TrailConnector()
	local trail = dash.Trail:Clone()
	trail.Attachment0 = humanoidRootPart.TrailAttachment0
	trail.Attachment1 = humanoidRootPart.TrailAttachment1
	trail.Parent = humanoidRootPart
	
	kickAnimationTrack:Play()
	
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = humanoidRootPart.RootRigAttachment
	linearVelocity.MaxForce = 100000
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = Vector3.new(0,0,-100)
	linearVelocity.Parent = humanoidRootPart
	task.wait(0.1)
	linearVelocity:Destroy()
	trail:Destroy()
end


local function SwordMove1()

	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://18346705526"

	-- Load the animation onto the animator
	local AnimationTrack = humanoid:LoadAnimation(Animation)
	AnimationTrack:Play()
	task.spawn(function()	
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = humanoidRootPart.RootRigAttachment
	linearVelocity.MaxForce = 1000000
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = Vector3.new(0,0,-100)
	linearVelocity.Parent = humanoidRootPart
	task.wait(0.1)
	linearVelocity:Destroy()
	end)
end


local function Heal()
	if humanoid.Health ~= nil then
		if humanoid.Health < 100 then
			humanoid.Health += 10
		end
	end
end

local function selfDamage()
	humanoid.Health -= 10
end


local function SpeedSet(Speed)
	if humanoid.Health ~= nil then
		humanoid.WalkSpeed = Speed
	end
end




local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local controlModule = require(playerModule:WaitForChild("ControlModule"))

local camera = workspace.CurrentCamera

local flying = false
local isjumping = false

local bodyVelocity = Instance.new("BodyVelocity")
local bodyGyro = Instance.new("BodyGyro")

bodyVelocity.MaxForce = Vector3.new(1,1,1)* 10^6
bodyVelocity.P = 10^6
bodyGyro.MaxTorque = Vector3.new(1,1,1)* 10^6
bodyGyro.P = 10^6


local function stateChange(old, new)
	if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Freefall then
		isjumping = true
	elseif new == Enum.HumanoidStateType.Landed then
		isjumping = false
	end
end




local function ToggleFlight()
	if not isjumping or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end
		flying = not flying
		bodyVelocity.Parent = flying and humanoidRootPart or nil
		bodyGyro.Parent = flying and humanoidRootPart or nil
		bodyGyro.CFrame = humanoidRootPart.CFrame
		bodyVelocity.Velocity = Vector3.new()

		character.Animate.Disabled = flying

		if flying then
			while flying do

				local movevector = controlModule:GetMoveVector()

				local direction = camera.CFrame.RightVector * (movevector.X) + camera.CFrame.LookVector * (movevector.Z * -1)

				if direction:Dot(direction) > 0 then
					direction = direction.Unit
				end

				bodyGyro.CFrame = camera.CFrame
				bodyVelocity.Velocity = direction * 100

				if humanoid.MoveDirection ~= Vector3.new() then
					-- Animations
				end
				wait()
			end
		end
	end



-- Play the animation track

local UserInputService = game:GetService("UserInputService")


humanoid.stateChanged:Connect(stateChange)


function Connector(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Y then
		Dash()		
	elseif input.KeyCode == Enum.KeyCode.L then
		Slash()
	elseif input.KeyCode == Enum.KeyCode.Z then
		Heal()
	elseif input.KeyCode == Enum.KeyCode.Space then
		ToggleFlight()
	elseif input.KeyCode == Enum.KeyCode.M then
		SpeedSet(50)
		
	end
end


UserInputService.InputBegan:Connect(Connector)
