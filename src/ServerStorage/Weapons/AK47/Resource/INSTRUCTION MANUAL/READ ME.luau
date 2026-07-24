--[[
	
	Hey Guys! Thanks for using my kit! And to clear any and all BS, yes this kit is made by StoneFox_Alfa. 
	There are quite a few things I'd like to add here. The main reason my non-FE version of this kit didn't have an instruction manual
	is mainly because it was taken from me and then leaked before it was completed. I took steps this time to ensure this didn't happen again :)
	Be nice and give credit where it is due! Anyway.. Let's get into it.
	
	--// SET-UP INSTRUCTIONS
		- To properly set up the kit, there are a few mandatory steps you must take. 
		- Keep in mind that this kit is meant for realism, as there is no crosshair UI, or ammunitions UI. 
		- There are 5 main components to get this thing working. 
		- Before we get into the above statement, we do the most important step of all:
			I. Select the tool itself, and in your properties pannel, under the behavior ribbon, there are 4 arguments. 
				Archivable, CanBeDropped, ManualActivationOnly, and RequiresHandle.
				Make absolute positive that you have ManualActivationOnly and RequiresHandle UNCHECKED. 
				The way my kit works is it creates that handle weld manually. That way it adds more customizablility.
				What the RequiresHandle does is create a basic weld on equipped. So that's why you'll see the gun spawn on the ground rather
				than in your hands if that bit is checked. 

			II. Next.. You need to select every single part inside the tool and have each of them Anchored and Non-Collidable. 
				Turnning off collisions will reduce lag immensely. Anchoring them will allow the scripts to weld the parts correctly
				so that they are not floating around weirdly. You do not need a third party welding script.
				
			III. Now you have the 5 main components: FirePart, Grip, AimPart, Mag, and Bolt.
				Each of these components must be named as they show above. You will also need all the children of those parts as well. I strongly suggest
				you copy and paste these components into any other gun you're making using this kit. That way you don't screw up. 
			
		- That's pretty much it for the set-up. Everything, provided that you did exactly as described above correctly should work like a charm.
			I have put a lot of work and heart into this project as it will probably be my final gift to the community before I ship for basic training in the
			U.S. Army. So please, have fun and enjoy!
			
		NOTE: PLEASE keep in mind that there will ALWAYS be additions to this kit. Whatever version you are using right now, there will be a next one bigger and better.
			Please have patience as well. If you have any questions, reguarding the kit, join the discord server linked below and ask for help! That easy.
			
		MODDING INSTRUCTIONS: 
			- Alright so by modding, you are basically swapping configurations using the client and server config modules in the SettingsModule folder. 
			- To get this to work, identify what type of configureation it is you are installing. You'll need to install both the server and client modules. 
			- To do this, delete both the modules located in the SettingsModule folde, then go check the Modulations folder and grab the two modules from the folder
				you wish to use, then drop the copies into the SettingsModule folder. When you first run the game, they'll initialize and boom. Ready. 
		
		LAST UPDATE:
			- Added Modding
			- Added Variable Zoom / Sight Swapping
			- Added Tactical and Standard Reloading
			- Shell Ejection
			- Bolt Action Fire Mode
			- 3rd Person
			- Flashlight (Client/Server side togglable)
			- Sensitivity Management
			- Laser Sights (Client Side)
			- Making Hitsounds and particle effects server side (So everyone can see them)
			- Jamming and Jam Clearing Mechanics
			- Idle Animation
			- A few mechanical tweeks
			
		PLANED UPDATES: 
			
			- Serverside Animations
			- Ambient Sound Manipulation (Sounds vary based on distance)
			- Explosive Firemode
			
		UPDATE INSTRUCTIONS: 
			I. Variable Zoom / Sight Swapping
				- This is a very simple addition. You can either just have this as variable zoom to toggle through or you could have it set up for sight swapping.
				- For variable zoom only, all you need to do is go into the tool, clone the AimPart, and them name it "AimPart2". Don't move it. 
				- For sight swapping, simply clone the AimPart and name it "AimPart2", then move it to the position of the second sight.
				- To edit the zoom amounts, go into the Client_Config and edit Zoom variables. It's pretty self explanitory. 
			II. Shell Ejection Set-Up
				- For this, you'll need to either use the shell provided in this release model, or your own. Simply hide the shell itself inside the gun and name it "Shell". 
					The rest takes care of itself. 
				- Keep in mind shell ejection is optional. If you don't want it, then just don't have a shell part. Simple. The gun won't glitch or error. 
		
			III. Third And First Person
				- The way this weapon system works is that it's got both third and first person mashed into one script
				- If you go to the client_config, you'll find that you can enable/disable first person only
				- If you turn off first person only, you'll have both third and first available
				- If you have FPS only disabled, to change your sensitivity, use the brackets "[" and "]"
				- If you have FPS only enabled, you can use either the brackets or the mouse wheel for sensitivity
						
		
		PLANNED UPDATES: 
			For the next updates, there will be simple bug fixes, code clean up, and the following: 
			
			- Holstering
			- Update on on welding mechanism 
			- Improved performance
			- Small update and fix to shotgun Firemode
			- Tracers will become serverside (optional in settings)
			- Customizable impact sounds
			- Minor code clean up
			
			Now for the cherry on top, on Friday's big update, February 16th, I will be releasing the prototype explosive firemode. 
	
	SUPPORT DISCORD SERVER: https://discord.gg/EcuFrjT
	
--]]
