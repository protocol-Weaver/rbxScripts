-- Wait For Game to Load
repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player and Character References
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Animation Objects
local animator = humanoid:FindFirstChildOfClass("Animator")
local kickAnimation = Instance.new("Animation")

-- Abilities and Cooldowns
local abilities = {
	Dash = { cooldown = 3, staminaCost = 30 },
	Slash = { cooldown = 2, staminaCost = 20 },
}
local lastAbilityTime = { Dash = 0, Slash = 0 }

-- Stamina Management
local maxStamina = 1000
local stamina = maxStamina
local staminaRegenRate = 50 -- Per second


-- Flight Management

-- Create a new BodyVelocity instance
local bodyVelocity = Instance.new("BodyVelocity")
local alignOrientation = Instance.new("AlignOrientation")

-- Set the maximum force for the BodyVelocity to a high value
bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10^6
-- Set the power (P) value for the BodyVelocity
bodyVelocity.P = 10^6


-- Utility Functions

--- Checks if the player can use a specified ability based on cooldown and stamina.
-- This function verifies if the ability is off cooldown and if the player has enough stamina to use it.
-- If both conditions are met, it updates the last usage time and reduces stamina accordingly.
-- @param ability The name of the ability to check.
-- @return boolean Whether the ability can be used.
local function canUseAbility(ability)
	local currentTime = tick()  -- Get the current time

	-- Check if the ability is on cooldown
	if currentTime - lastAbilityTime[ability] < abilities[ability].cooldown then
		warn(ability .. " is on cooldown!")
		return false
	end

	-- Check if the player has enough stamina
	if stamina < abilities[ability].staminaCost then
		warn("Not enough stamina to use " .. ability .. "!")
		return false
	end

	-- Update the last ability time and reduce stamina
	lastAbilityTime[ability] = currentTime
	stamina = stamina - abilities[ability].staminaCost
	return true
end

--- Creates a trail effect by attaching trail attachments to the humanoid root part.
-- This function creates two attachments on the humanoid root part to generate a trail effect when the player dashes.
local function createTrail()
	-- Create the first attachment for the trail
	local trailAttachment0 = Instance.new("Attachment")
	trailAttachment0.Name = "TrailAttachment0"
	trailAttachment0.Parent = humanoidRootPart

	-- Create the second attachment for the trail
	local trailAttachment1 = Instance.new("Attachment")
	trailAttachment1.Name = "TrailAttachment1"
	trailAttachment1.Position = Vector3.new(0, 1.5, 0)
	trailAttachment1.Parent = humanoidRootPart
end

--- Initializes and plays the slash effect with animated textures.
-- This function creates a slash effect in the game world. It rotates the effect using a tween and animates it with different textures.
local function initializeSlashEffect()
	-- Clone the slash mesh from ReplicatedStorage
	local slashMesh = ReplicatedStorage.Slash:Clone()
	slashMesh.CFrame = CFrame.new(0, 0, 0)
	slashMesh.Mesh.VertexColor = Vector3.new(10, 0, 0)
	slashMesh.Parent = workspace  -- Parent the mesh to the workspace

	-- Create a CFrameValue to control rotation
	local rotationValue = Instance.new("CFrameValue")

	-- Create a tween to rotate the mesh
	local tween = TweenService:Create(rotationValue, TweenInfo.new(0.3), { Value = CFrame.Angles(0, math.rad(-90), math.rad(-90)) })

	-- Connect to RenderStepped to update the mesh's CFrame
	local moveConnection = RunService.RenderStepped:Connect(function()
		slashMesh.CFrame = character:GetPivot() * rotationValue.Value
	end)

	-- Play the rotation tween
	tween:Play()

	-- List of textures to animate the slash effect
	local animationImages = {
		"rbxassetid://18357231142",
		"rbxassetid://18357230843",
		"rbxassetid://18356887208",
		"rbxassetid://18356887551",
	}

	-- Cycle through textures to animate the slash effect
	task.spawn(function()
		for _, texture in ipairs(animationImages) do
			slashMesh.Mesh.TextureId = texture
			task.wait(0.05)  -- Wait between texture changes
		end

		-- Cleanup after the animation finishes
		moveConnection:Disconnect()
		rotationValue:Destroy()
		slashMesh:Destroy()
	end)
end

--- Performs the slash ability, playing the corresponding animation and initializing the slash effect.
-- This function triggers the slash animation and then calls the function to initialize the visual slash effect.
local function performSlash()
	-- Check if the ability can be used
	if not canUseAbility("Slash") then return end

	-- Create and play the slash animation
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://18419828546"

	local track = animator:LoadAnimation(animation)
	track:Play()
	track.Stopped:Wait()  -- Wait for the animation to finish

	-- Initialize the slash effect
	initializeSlashEffect()
end

--- Performs the dash ability, creating a dash effect and moving the player forward.
-- This function makes the player dash forward, creating a visual trail and playing a dash animation.
local function performDash()
	-- Check if the ability can be used
	if not canUseAbility("Dash") then return end

	-- Create the trail effect for the dash
	createTrail()

	-- Clone the dash trail and set its attachments
	local dashTrail = ReplicatedStorage.Dash.Trail:Clone()
	dashTrail.Attachment0 = humanoidRootPart.TrailAttachment0
	dashTrail.Attachment1 = humanoidRootPart.TrailAttachment1
	dashTrail.Parent = humanoidRootPart

	-- Create and play the dash animation
	kickAnimation.AnimationId = "rbxassetid://18314102259"
	local animationTrack = animator:LoadAnimation(kickAnimation)
	animationTrack:Play()

	-- Create linear velocity to propel the character forward
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = humanoidRootPart.RootRigAttachment
	linearVelocity.MaxForce = 100000
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = Vector3.new(0, 0, -100)
	linearVelocity.Parent = humanoidRootPart

	-- Wait for a short duration before cleaning up
	task.wait(0.1)

	-- Cleanup the velocity and trail after the dash
	linearVelocity:Destroy()
	dashTrail:Destroy()
end

--- Heals the player by a fixed amount, up to the maximum health.
-- This function increases the player's health by 10, but ensures that health does not exceed 100.
local function healPlayer()
	if humanoid.Health and humanoid.Health < 100 then
		humanoid.Health = math.min(humanoid.Health + 10, 100)
	end
end

--- Reduces the player's health by a fixed amount, down to a minimum of 0.
-- This function decreases the player's health by 10, but ensures that health does not go below 0.
local function damageSelf()
	if humanoid.Health then
		humanoid.Health = math.max(humanoid.Health - 10, 0)
	end
end

--- Sets the player's walk speed to the specified value.
-- This function allows you to change the player's walk speed.
-- @param speed The new walk speed to set.
local function setSpeed(speed)
	humanoid.WalkSpeed = speed
end

-- Flight Mechanics
local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local controlModule = require(playerModule:WaitForChild("ControlModule"))
local camera = workspace.CurrentCamera

local flying = false
local isJumping = false

--- Handles the state change of the humanoid, specifically tracking jumping and freefall states.
-- This function tracks whether the player is in a jumping or freefall state, which is necessary for enabling flight.
-- @param oldState The old state of the humanoid.
-- @param newState The new state of the humanoid.
local function onStateChanged(old, new)
	if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Freefall then
		isJumping = true
	elseif new == Enum.HumanoidStateType.Landed then
		isJumping = false
	end
end




--- Toggles the player's flight mode, allowing the player to fly when in a freefall state.
-- This function allows the player to toggle flight mode when in a freefall state. It uses body velocity and align orientation to control flight direction and speed.
-- Toggles Flight Mode and makes the player fly using AlignOrientation to float and BodyVelocity to move
local function ToggleFlight()

	-- Check if the player is jumping and in freefall state
	if not isJumping or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end


	-- Toggle the flying state
	flying = not flying -- Toggles Flight Mode

	-- AlignOrientation used for Rotational Force and to indicate where the body will be pointing and BodyVelocity to move in a Direction

	bodyVelocity.Parent = flying and humanoidRootPart or nil
	alignOrientation.Parent = flying and humanoidRootPart or nil
	alignOrientation.CFrame = humanoidRootPart.CFrame
	bodyVelocity.Velocity = Vector3.new()

	-- Disable default animations when flying
	character.Animate.Disabled = flying -- Blocks Default Animation

	if flying then
		while flying do
			-- Gets movement vector from control module
			local movevector = controlModule:GetMoveVector() -- Gets CFrame From Control Module

			-- Changing direction based on player camera
			local direction = camera.CFrame.RightVector * (movevector.X) + camera.CFrame.LookVector * (movevector.Z * -1)

			-- Normalize direction vector if it's not zero
			if direction:Dot(direction) > 0 then
				direction = direction.Unit
			end

			-- Changing body direction with respect to camera and making it move forward
			alignOrientation.CFrame = camera.CFrame
			bodyVelocity.Velocity = direction * 100
			wait()
		end
	end
end

-- Stamina Regeneration

--- Regenerates the player's stamina over time, capped at the maximum stamina.
-- This function gradually regenerates the player's stamina each frame, ensuring it does not exceed the maximum limit.
-- @param dt The delta time since the last frame.
RunService.Heartbeat:Connect(function(dt)
	stamina = math.min(stamina + staminaRegenRate * dt, maxStamina)
end)

-- User Input Handler

--- Handles the player's input to trigger abilities based on key presses.
-- This function listens for specific key presses and triggers the corresponding ability, such as dashing, slashing, or toggling flight.
-- @param input The input object representing the player's input.
-- @param gameProcessed Whether the game has processed the input already.
local function handleInput(input, gameProcessed)
	-- Ignore input if the game has already processed it
	if gameProcessed then return end

	-- Check which key was pressed and trigger the corresponding ability
	if input.KeyCode == Enum.KeyCode.Y then
		performDash()
	elseif input.KeyCode == Enum.KeyCode.L then
		performSlash()
	elseif input.KeyCode == Enum.KeyCode.Z then
		healPlayer()
	elseif input.KeyCode == Enum.KeyCode.Space then
		ToggleFlight()
	elseif input.KeyCode == Enum.KeyCode.M then
		setSpeed(50)
	end
end

-- Connections
humanoid.StateChanged:Connect(onStateChanged)
UserInputService.InputBegan:Connect(handleInput)
