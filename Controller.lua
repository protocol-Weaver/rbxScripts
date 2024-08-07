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

-- Dash Effect Trail Creator using 2 Trail Attachments
local function TrailConnector()
    -- Create the first trail attachment and parent it to the humanoid root part
    local trailAttachment0 = Instance.new("Attachment")
    trailAttachment0.Name = "TrailAttachment0"
    trailAttachment0.Parent = humanoidRootPart
    
    -- Create the second trail attachment, position it, and parent it to the humanoid root part
    local trailAttachment1 = Instance.new("Attachment")
    trailAttachment1.Name = "TrailAttachment1"
    trailAttachment1.Position = trailAttachment0.Position + Vector3.new(0, 1.5, 0)
    trailAttachment1.Parent = humanoidRootPart
end



-- Sets the size of a SpecialMesh object
local function SetVectorToSpecialMesh(SpecialMesh, Size)
    -- Get the parent part of the SpecialMesh
    local Part = SpecialMesh.Parent
    -- Calculate the original size of the part based on the SpecialMesh scale
    local OriginalSize = Part.Size / SpecialMesh.Scale
    -- Set the new size of the part
    Part.Size = Size
    -- Adjust the SpecialMesh scale to match the new size
    SpecialMesh.Scale = Size / OriginalSize
end

-- Initializes the slash effect
local function SlashInit()
    -- Get the sword tool from the StarterPack
    local sword = game:GetService("StarterPack").Tool
    -- Clone the Slash mesh from storage
    local SlashMesh = storage.Slash:Clone()
    -- Set the vertex color of the Slash mesh
    local VertexColor = Vector3.new(10, 0, 0)
    -- Define the size of the Slash mesh
    local Size = Vector3.new(13, 1, 12)
    -- Define the initial CFrame value
    local CFrameVal = CFrame.new(0, 0, 0)
    -- Define the start rotation
    local StartRotation = CFrame.Angles(0, 0, 0)
    -- Define the rotation amount
    local RotationAmount = CFrame.Angles(0, -90, -90)
    -- Define the time interval for animation images
    local Time = 0.05
    -- Set the parent of the Slash mesh to the workspace
    local Parent = workspace
    -- Define the tween rotation info
    local TweenRotationInfo = TweenInfo.new(0.3)
    -- Define the tween rotational goal
    local TweenRotationalGoal = {Value = RotationAmount}
    -- List of animation image asset IDs
    local AnimationImages = {
        "rbxassetid://18357231142",
        "rbxassetid://18357230843",
        "rbxassetid://18356887208",
        "rbxassetid://18356887551",
    }
    -- Set the vector to the Slash mesh
    SetVectorToSpecialMesh(SlashMesh.Mesh, Size)
    -- Set the CFrame of the Slash mesh
    SlashMesh.CFrame = CFrameVal
    -- Set the vertex color of the Slash mesh
    SlashMesh.Mesh.VertexColor = VertexColor
    -- Set the parent of the Slash mesh
    SlashMesh.Parent = Parent
    
    -- Create a new CFrameValue for rotation
    local RotationValue = Instance.new("CFrameValue")
    -- Create and play the tween for rotation
    TweenService:Create(RotationValue, TweenRotationInfo, TweenRotationalGoal):Play()
    -- Connect the RenderStepped event to update the Slash mesh CFrame
    local MoveConnection = game:GetService("RunService").RenderStepped:Connect(function()
        SlashMesh.CFrame = character:GetPivot() * StartRotation * RotationValue.Value
    end)
    -- Spawn a new task to handle the animation images
    task.spawn(function()
        for _i, textures in pairs(AnimationImages) do 
            -- Set the texture ID of the Slash mesh
            SlashMesh.Mesh.TextureId = textures    
            -- Wait for the specified time interval
            task.wait(Time)
        end
        -- Disconnect the RenderStepped event
        MoveConnection:Disconnect()
        -- Destroy the rotation value and Slash mesh
        RotationValue:Destroy()
        SlashMesh:Destroy()
    end)
end

-- Plays the slash animation
local function Slash()
    -- Create a new animation instance
    local Animation = Instance.new("Animation")
    -- Set the animation ID
    Animation.AnimationId = "rbxassetid://18419828546"
    -- Load the animation onto the humanoid animator
    local Track = humanoid.Animator:LoadAnimation(Animation)
    -- Play the animation
    Track:Play()
    -- Wait for the animation to stop
    Track.Stopped:Wait()
    -- Initialize the slash effect
    SlashInit()
end



-- Using Linear Velocity to Create A Movement And playing movement animation and using trail effect to display A Dash.
local function Dash()
    -- Creates Dash Effect by connecting trail attachments
    TrailConnector()
    
    -- Clone the dash trail and set its attachments to the humanoid root part
    local trail = dash.Trail:Clone()
    trail.Attachment0 = humanoidRootPart.TrailAttachment0
    trail.Attachment1 = humanoidRootPart.TrailAttachment1
    trail.Parent = humanoidRootPart

    -- Play the dash animation
    kickAnimationTrack:Play()

    -- Create linear velocity to make the humanoid move forward for dashing
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Attachment0 = humanoidRootPart.RootRigAttachment
    linearVelocity.MaxForce = 100000
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    linearVelocity.VectorVelocity = Vector3.new(0, 0, -100)
    linearVelocity.Parent = humanoidRootPart
    
    -- Wait for a short duration before destroying the objects
    task.wait(0.1)
    
    -- Destroy the linear velocity and trail objects to clean up
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

-- Create a new BodyVelocity instance
local bodyVelocity = Instance.new("BodyVelocity")
-- Create a new BodyGyro instance
local bodyGyro = Instance.new("BodyGyro")

-- Set the maximum force for the BodyVelocity to a high value
bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10^6
-- Set the power (P) value for the BodyVelocity
bodyVelocity.P = 10^6

-- Set the maximum torque for the BodyGyro to a high value
bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10^6
-- Set the power (P) value for the BodyGyro
bodyGyro.P = 10^6


-- Toggles From Jumping To Flying Or Flying to Jumping
local function stateChange(old, new)
	if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Freefall then
		isjumping = true
	elseif new == Enum.HumanoidStateType.Landed then
		isjumping = false
	end
end


-- Toggles Flight Mode and makes the player fly using Body Gyro to float and Body Velocity to move
local function ToggleFlight()
    -- Check if the player is jumping and in freefall state
    if not isjumping or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end
    
    -- Toggle the flying state
    flying = not flying -- Toggles Flight Mode
    
    -- Body Gyro used for Rotational Force and to indicate where the body will be pointing and BodyVelocity to move in a Direction
    bodyVelocity.Parent = flying and humanoidRootPart or nil
    bodyGyro.Parent = flying and humanoidRootPart or nil
    bodyGyro.CFrame = humanoidRootPart.CFrame
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
            bodyGyro.CFrame = camera.CFrame
            bodyVelocity.Velocity = direction * 100
            wait()
        end
    end
end

humanoid.stateChanged:Connect(stateChange) -- Changes Jumping State


local UserInputService = game:GetService("UserInputService") -- Service Required For Player Input

-- Receives Input key and calls function in accordance to that key
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
