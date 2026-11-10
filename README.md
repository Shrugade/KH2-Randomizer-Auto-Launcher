
# KH2 Randomizer Auto Launcher

A Steam Deck launcher for Kingdom Hearts II Final Mix that automates launching KH2 alongside KH2 Tracker and LiveSplit in a shared Wine virtual desktop.

## Requirements

The following software must be downloaded and installed separately:

- Kingdom Hearts II Final Mix (Steam version)
- KH2 Tracker
- LiveSplit
- KH2 Load Remover

The Steam Deck must also have the following components installed:

- SteamOS
- Steam Linux Runtime Sniper
- Gamescope
- MangoHud
- xdotool
- Python 3

### Required VC++ Runtime Dependencies

The launcher requires the following four DLL files to be present in the KH2 game directory:

- `msvcp140.dll`
- `vcruntime140.dll`
- `vcruntime140_1.dll`
- `dependencies/msvcp140.dll`

**All four files are required.** The second copy of `msvcp140.dll` must be placed inside the game's `dependencies` directory.

The expected directory structure is:

```text
KINGDOM HEARTS -HD 1.5+2.5 ReMIX-/
├── msvcp140.dll
├── vcruntime140.dll
├── vcruntime140_1.dll
└── dependencies/
    └── msvcp140.dll
```

These files must be obtained separately and installed before running the launcher. The launcher does not download or install these dependencies.

**Do not substitute unrelated DLL versions.** Use the appropriate runtime files for your KH2 installation.

### Optional: KH2Moose Support

The launcher includes full KH2Moose compatibility, including memory-block allocation functionality.

**KH2Moose is not required to use this launcher.** It is an optional addition for users who want to use KH2Moose with their modded sessions. Many KH2 mods already bundle KH2Moose with their files, so a separate installation is generally unnecessary when it is already included with a mod.

The launcher does not download, install, or automatically configure KH2Moose or any other mods.

## Installation

1. Click the green **Code** button.
2. Select **Download ZIP**.
3. Extract the downloaded ZIP file to your preferred location on the Steam Deck.
4. Download and install KH2 Tracker.
5. Download and install LiveSplit.
6. Download and install KH2 Load Remover.
7. Obtain the four required VC++ runtime DLL files and place them in the KH2 game directory using the directory structure shown above.
8. Ensure that `KhTracker.exe` and `LiveSplit.exe` are located somewhere within your home directory.

**Important:** Verify that all four DLL files are present before launching the script.

## Usage

1. Open the extracted launcher folder in Steam Deck Desktop Mode.
2. Run `Launch-KH2-Auto.sh`.
3. The launcher automatically detects your KH2 installation, Proton version, and required executable paths.
4. KH2 launches through Gamescope with full KH2Moose compatibility.
5. Wait until the actual KH2 title screen appears.
6. Press **ENTER** in the launcher terminal.
7. KH2 Tracker and LiveSplit launch automatically in the shared Wine virtual desktop.

## Important Notes

- Always launch the script from Steam Deck Desktop Mode.
- Do not close the launcher terminal while the game is running.
- KH2 Tracker and LiveSplit are launched after you reach the actual KH2 title screen.
- KH2 Load Remover must be installed separately. The launcher does not install it.
- All four VC++ runtime DLL files are required.
- KH2Moose is optional and is not a dependency of the launcher.
- Mods and their associated files must be installed separately.

## KH2Moose Compatibility

The launcher includes compatibility adjustments that allow KH2Moose to use its full functionality, including its memory-block allocation features.

This is intended to provide a seamless experience for sessions using KH2Moose, regardless of which mod includes or uses it.

KH2Moose is an additional feature supported by the launcher, not a requirement for standard randomizer sessions.
