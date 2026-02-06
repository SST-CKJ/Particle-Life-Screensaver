# Particle Life Screensaver
Particle Life Screensaver is a native macOS screensaver featuring particles that exhibit emergent life-like behavior in a physics simulation through randomly generated attraction and repulsion rules. Despite the simplicity of the underlying rules, complex can patterns emerge.

This screensaver brings the captivating [Particle Life simulation](https://github.com/hunar4321/particle-life) by hunar4321 to macOS as a native `.saver` implementation.

## Installation
There are 2 options for you to install the screensaver, with option 1 being the easier option for the general public

### Option 1: Download the Lastest Release
#### Prerequisites
- macOS Sequoia 15.4

#### Steps
1. Navigate to the [latest release]([https://github.com/SST-CKJ/Particle-Life-Screensaver/releases/tag/v1.0.0](https://github.com/SST-CKJ/Particle-Life-Screensaver/releases))
2. Download `Particle.Life.saver.zip` under assets
3. Unzip the file
4. Double-click the extracted `.saver` file
5. If the `.saver` file cannot be opened due security reasons, (this is because apple does not trust unknown developers)
    1. Open settings and go to the **Privacy & Security** tab
    2. Scroll down until you see `Particle Life.saver`  was blocked to protect your Mac and click **Open Anyway**
6. When prompted, select **Install**
7. Open **System Settings → Screen Saver** and select "Particle Life" from the available screensavers (it is usually housed under the **Others** category)

### Option 2: Download the Source Code
#### Prerequisites
- macOS Sequoia 15.4 or later
- Xcode 14 or later

#### Steps
1. Scroll up and click the green **Code** button, and click **Download ZIP** in the dropdown menu
2. Unzip the folder
3. Open the project using Xcode
4. You are free to edit the code to your liking!

To export the source code as a `.saver` file from Xcode,
1. Go to **Product → Archive**, then wait for it to build
2. A new window called **Archives** will pop up
3. Select the right archive, click **Distribute Content → Custom → Built Products**
4. Select the directory you wish to store the file in

## Credits
Inspired by [hunar4321's Particle Life simulator](https://github.com/hunar4321/particle-life).
Alexander for testing my product.
