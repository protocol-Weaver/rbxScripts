-- Wait For Game to Load
repeat task.wait() 
until game:IsLoaded()

-- Access to Players Data and Studio Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")
local storage = game:GetService("ReplicatedStorage")
local storage = game:GetService("ReplicatedStorage")

-- Dash Effect From Storage
local dash = storage.Dash

-- Create a new "Animation" instance and assign an animation asset ID
local kickAnimation = Instance.new("Animation")
kickAnimation.AnimationId = "rbxassetid://18314102259"

-- Load the animation onto the animator
local kickAnimationTrack = humanoid:LoadAnimation(kickAnimation)

-- Resizing The Slash Mesh
local function SetVectorToSpecialMesh(SpecialMesh, Size)
	local Part = SpecialMesh.Parent
	local OriginalSize = Part.Size / SpecialMesh.Scale
	Part.Size = Size
	SpecialMesh.Scale = Size / OriginalSize
end

-- Creating Slash Animation Effect
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
	-- Using Tween Service On The Mesh
	local TweenRotationInfo = TweenInfo.new(0.3)
	local TweenRotationalGoal = {Value = RotationAmount}
	-- Texture For Slash Animation
	local AnimationImages = {
		"rbxassetid://18357231142",
		"rbxassetid://18357230843",
		"rbxassetid://18356887208",
		"rbxassetid://18356887551",
	}
	
	SetVectorToSpecialMesh(SlashMesh.Mesh, Size) -- Resizing
	-- Changing Slash Mesh Data
	SlashMesh.CFrame = CFrameVal
	SlashMesh.Mesh.VertexColor = VertexColor
	SlashMesh.Parent = Parent

	local RotationValue = Instance.new("CFrameValue")
	
	TweenService:Create(RotationValue, TweenRotationInfo, TweenRotationalGoal):Play() -- Rotates the Slash Mesh
	
	local MoveConnection = game:GetService("RunService").RenderStepped:Connect(function()
		SlashMesh.CFrame = character:GetPivot() * StartRotation * RotationValue.Value  -- Responsible for Rotating Slash Mesh
	end)
	
	task.spawn(function()
		-- Creating Slash Animation From Texture Display	
		for _i , textures in pairs(AnimationImages) do 
			SlashMesh.Mesh.TextureId = textures	
			task.wait(Time)
		end
		-- Destroying Objects At the End
		MoveConnection:Disconnect()
		RotationValue:Destroy()
		SlashMesh:Destroy()
	end)
end

-- Plays The Slash Animation Effect
local function Slash()
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://18419828546"
	local Track = humanoid.Animator:LoadAnimation(Animation) -- Loads The Sword Animation
	Track:Play()
	Track.Stopped:Wait()
	SlashInit() -- Creates A Red Slash Effect
end

-- Creates A FireBall Effect Using Textures
local function FireBall()

	-- Data
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
	-- FireBall Animation Effect
	task.spawn(function()
		while true do
		for _i , textures in pairs(AnimationImages) do 
			SlashMesh.Mesh.TextureId = textures	
			task.wait(Time)
			end 
		end
		SlashMesh:Destroy()
	end)
end

-- Dash Effect Trail Creator using 2 Trail Attachments
local function TrailConnector()
	local trailAttachment0 = Instance.new("Attachment")
	trailAttachment0.Name = "TrailAttachment0"
	trailAttachment0.Parent = humanoidRootPart
	
	local trailAttachment1 = Instance.new("Attachment")
	trailAttachment1.Name = "TrailAttachment1"
	trailAttachment1.Position = trailAttachment0.Position + Vector3.new(0,1.5,0)
	trailAttachment1.Parent = humanoidRootPart
end

-- Plays The Dash Animation
local function Dash()
	-- Creates Dash Effect
	TrailConnector()
	local trail = dash.Trail:Clone()
	trail.Attachment0 = humanoidRootPart.TrailAttachment0
	trail.Attachment1 = humanoidRootPart.TrailAttachment1
	trail.Parent = humanoidRootPart

	-- Plays the Dash animation
	kickAnimationTrack:Play()

	-- Makes the Humanoid Move Forward For Dashing
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = humanoidRootPart.RootRigAttachment
	linearVelocity.MaxForce = 100000
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = Vector3.new(0,0,-100)
	linearVelocity.Parent = humanoidRootPart
	task.wait(0.1)
	-- Destorying Objects
	linearVelocity:Destroy()
	trail:Destroy()
end
-- Heals The Player Health
local function Heal()
	if humanoid.Health ~= nil then
		if humanoid.Health < 100 then
			humanoid.Health += 10 -- Increasing Health
		end
	end
end

-- Damages One self Health
local function selfDamage()
	humanoid.Health -= 10
end

-- Sets Humanoid Speed To given Input
local function SpeedSet(Speed)
	if humanoid.Health ~= nil then
		humanoid.WalkSpeed = Speed
	end
end


-- Stuff Needed For Flight Movement
local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local controlModule = require(playerModule:WaitForChild("ControlModule"))
local camera = workspace.CurrentCamera

local flying = false
local isjumping = false

-- This Makes the Body Able to Fly 
local bodyVelocity = Instance.new("BodyVelocity")
local bodyGyro = Instance.new("BodyGyro")

bodyVelocity.MaxForce = Vector3.new(1,1,1)* 10^6
bodyVelocity.P = 10^6
bodyGyro.MaxTorque = Vector3.new(1,1,1)* 10^6
bodyGyro.P = 10^6

-- Toggles From Jumping To Flying Or Flying to Jumping
local function stateChange(old, new)
	if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Freefall then
		isjumping = true
	elseif new == Enum.HumanoidStateType.Landed then
		isjumping = false
	end
end


-- Toggles Flight Mode
local function ToggleFlight()
	if not isjumping or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end
		flying = not flying -- Toggles Flight Mode
		-- Data Required For Flight
		bodyVelocity.Parent = flying and humanoidRootPart or nil
		bodyGyro.Parent = flying and humanoidRootPart or nil
		bodyGyro.CFrame = humanoidRootPart.CFrame
		bodyVelocity.Velocity = Vector3.new()

		character.Animate.Disabled = flying -- Blocks Default Animation

		if flying then
			while flying do

				local movevector = controlModule:GetMoveVector() -- Gets CFrame From Control Module
				-- Changing Direction Based On Player Camera 
				local direction = camera.CFrame.RightVector * (movevector.X) + camera.CFrame.LookVector * (movevector.Z * -1)

				if direction:Dot(direction) > 0 then
					direction = direction.Unit
				end
`				-- Changing Body Direction w.r.t Camera + Making it Move Forward
				bodyGyro.CFrame = camera.CFrame
				bodyVelocity.Velocity = direction * 100
				wait()
			end
		end
	end

humanoid.stateChanged:Connect(stateChange) -- Changes Jumping State


local UserInputService = game:GetService("UserInputService") -- Service Required For Player Input

-- Controller that performs stuff based on Keys Pressed
function Connector(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Y then
		Dash()	-- Dash Animation	
	elseif input.KeyCode == Enum.KeyCode.L then
		Slash() -- Slash Effect
	elseif input.KeyCode == Enum.KeyCode.Z then
		Heal() -- Heal One Self
	elseif input.KeyCode == Enum.KeyCode.Space then
		ToggleFlight() -- Toggle Flight Mode
	elseif input.KeyCode == Enum.KeyCode.M then
		SpeedSet(50) -- Sets Body Speed 
	end
end


UserInputService.InputBegan:Connect(Connector) -- Listens For Keyboard Inputs
