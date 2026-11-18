local rofi_command = "rofi -show drun"

return {
    default = {
        terminal = "alacritty",
        rofi = rofi_command,
        lock = "i3lock-fancy",
        quake = "alacritty",
        screenshot = "flameshot screen -p ~/Pictures/etc",
        region_screenshot = "flameshot gui",
        delayed_screenshot = "flameshot screen -p ~/Pictures -d 5000",
        browser = "brave-browser",
        browser2 = "thorium-browser",
        editor = "codium",
        editor2 = "alacritty -e nvim",
        social = "discord",
        game = rofi_command,
        files = "pcmanfm",
        tfiles = "alacritty -e yazi",
        music = rofi_command,
    },

    run_on_start_up = {
        { command = "picom", process = "picom" },
        { command = "nm-applet --indicator", process = "nm-applet" },
        { command = "pnmixer", process = "pnmixer" },
        { command = "flameshot", process = "flameshot" },
        { command = "Telegram", process = "Telegram" },
    },

    run_on_start_up_commands = {
        "numlockx on",
        "nitrogen --restore",
        "xset r rate 250 35",
    },
}
