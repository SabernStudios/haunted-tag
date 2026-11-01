Haunted Tag
Haunted Tag is a multiplayer Roblox game I developed using Luau and Roblox Studio. Players compete in rounds of tag within a haunted manor, using character movement, tagging mechanics, power-ups, and customization systems.

I created this project to explore how increasingly complex gameplay systems can be organized into reusable components while remaining manageable during development.
Technical Highlights
Modular character architecture: BaseCharacterClass initializes specialized controllers responsible for movement, tagging, cooldowns, status effects, inventory, and other character behaviors.

State management: A custom state machine tracks movement, tagging, and status conditions, using transition rules to restrict incompatible actions.

Timed-state handling: Tokens identify active timed effects so outdated delayed callbacks do not override newer character states.

Round orchestration: The round system coordinates voting, map loading, player setup, gameplay timers, and results.

Server-side gameplay logic: Tagging and other character actions are processed through server-side systems, including validation checks.
Code Organization
- imported/ServerScriptService/Classes/Character/ — Base character architecture
- imported/ServerScriptService/Classes/Controllers/ — Specialized gameplay controllers
- imported/ServerScriptService/Services/ — Multiplayer and game-wide services
- imported/Shared/ — Shared definitions and modules
- imported/StarterPlayerScripts/ — Client-side scripts
- default.project.json — Rojo project mapping
Development Process
Development began in July 2026. I documented the implementation and testing process through recorded Roblox Studio development sessions.

Important challenges included coordinating character state transitions, handling overlapping timed actions, and maintaining a growing multiplayer codebase.
Tools
Roblox Studio, Luau, Rojo, Visual Studio Code, Git, and Blender.
Project Status
This repository documents the game's development-stage implementation. Some features remain incomplete or are still being refined. The source files alone may not reproduce every Studio asset and dependency.

A recorded working demonstration is included in my MIT Maker Portfolio.