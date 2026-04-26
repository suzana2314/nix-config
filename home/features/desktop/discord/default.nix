{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ unstable.vesktop ];

  xdg.configFile."vesktop/themes/gruvbox-24.theme.css".text = with config.colorScheme.palette; ''

    /**
     * @name gruvbox system24 (vencord)
     * @description a tui-style discord theme. based on https://github.com/nanoqoi/vencord-theme.
     * @author refact0r, suz
     * @version 2.0.0
     * @invite nz87hXyvcy
     * @website https://github.com/refact0r/system24
     * @source https://github.com/refact0r/system24/blob/master/theme/system24-vencord.theme.css
     * @authorId 508863359777505290
     * @authorLink https://www.refact0r.dev
    */

    /* import theme modules */
    @import url('https://refact0r.github.io/system24/build/system24.css');

    body {
        --font: "${config.fontProfiles.monospace.name}";
        --code-font: "${config.fontProfiles.monospace.name}";
        font-weight: 300; /* text font weight. 300 is light, 400 is normal. DOES NOT AFFECT BOLD TEXT */
        letter-spacing: -0.05ch; /* decreases letter spacing for better readability. recommended on monospace fonts.*/

        /* sizes */
        --gap: 12px; /* spacing between panels */
        --divider-thickness: 4px; /* thickness of unread messages divider and highlighted message borders */
        --border-thickness: 2px; /* thickness of borders around main panels. DOES NOT AFFECT OTHER BORDERS */
        --border-hover-transition: 0.2s ease; /* transition for borders when hovered */

        /* animation/transition options */
        --animations: on; /* off: disable animations/transitions, on: enable animations/transitions */
        --list-item-transition: 0.2s ease; /* transition for list items */
        --dms-icon-svg-transition: 0.4s ease; /* transition for the dms icon */

        /* top bar options */
        --top-bar-height: var(--gap); /* height of the top bar (discord default is 36px, old discord style is 24px, var(--gap) recommended if button position is set to titlebar) */
        --top-bar-button-position: titlebar; /* off: default position, hide: hide buttons completely, serverlist: move inbox button to server list, titlebar: move inbox button to channel titlebar (will hide title) */
        --top-bar-title-position: off; /* off: default centered position, hide: hide title completely, left: left align title (like old discord) */
        --subtle-top-bar-title: off; /* off: default, on: hide the icon and use subtle text color (like old discord) */

        /* window controls */
        --custom-window-controls: off; /* off: default window controls, on: custom window controls */
        --window-control-size: 14px; /* size of custom window controls */

        /* dms button options */
        --custom-dms-icon: off; /* off: use default discord icon, hide: remove icon entirely, custom: use custom icon */
        --dms-icon-svg-url: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 27 27' width='24' height='24'%3E%3Cpath fill='currentColor' d='M0 0h7v1H6v1H5v1H4v1H3v1H2v1h5v1H0V6h1V5h1V4h1V3h1V2h1V1H0m13 2h5v1h-1v1h-1v1h-1v1h3v1h-5V7h1V6h1V5h1V4h-3m8 5h1v5h1v-1h1v1h-1v1h1v-1h1v1h-1v3h-1v1h-2v1h-1v1h1v-1h2v-1h1v2h-1v1h-2v1h-1v-1h-1v1h-6v-1h-1v-1h-1v-2h1v1h2v1h3v1h1v-1h-1v-1h-3v-1h-4v-4h1v-2h1v-1h1v-1h1v2h1v1h1v-1h1v1h-1v1h2v-2h1v-2h1v-1h1M8 14h2v1H9v4h1v2h1v1h1v1h1v1h4v1h-6v-1H5v-1H4v-5h1v-1h1v-2h2m17 3h1v3h-1v1h-1v1h-1v2h-2v-2h2v-1h1v-1h1m1 0h1v3h-1v1h-2v-1h1v-1h1'%3E%3C/path%3E%3C/svg%3E"); /* icon svg url. MUST BE A SVG. */
        --dms-icon-svg-size: 90%; /* size of the svg (css mask-size property) */
        --dms-icon-color-before: var(--icon-subtle); /* normal icon color */
        --dms-icon-color-after: var(--white); /* icon color when button is hovered/selected */
        --custom-dms-background: off; /* off to disable, image to use a background image (must set url variable below), color to use a custom color/gradient */
        --dms-background-image-url: url(""); /* url of the background image */
        --dms-background-image-size: cover; /* size of the background image (css background-size property) */
        --dms-background-color: linear-gradient(70deg, var(--blue), var(--purple), var(--red)); /* fixed color/gradient (css background property) */

        /* background image options */
        --background-image: off; /* off: no background image, on: enable background image (must set url variable below) */
        --background-image-url: url(""); /* url of the background image */

        /* transparency/blur options */
        /* NOTE: TO USE TRANSPARENCY/BLUR, YOU MUST HAVE TRANSPARENT BG COLORS. FOR EXAMPLE: --bg-4: hsla(220, 15%, 10%, 0.7); */
        --transparency-tweaks: off; /* off: no changes, on: remove some elements for better transparency */
        --remove-bg-layer: off; /* off: no changes, on: remove the base --bg-3 layer for use with window transparency (WILL OVERRIDE BACKGROUND IMAGE) */
        --panel-blur: off; /* off: no changes, on: blur the background of panels */
        --blur-amount: 12px; /* amount of blur */
        --bg-floating: var(--bg-4); /* set this to a more opaque color if floating panels look too transparent. only applies if panel blur is on  */

        /* other options */
        --small-user-panel: off; /* off: default user panel, on: smaller user panel like in old discord */

        /* unrounding options */
        --unrounding: off; /* off: default, on: remove rounded corners from panels */

        /* styling options */
        --custom-spotify-bar: on; /* off: default, on: custom text-like spotify progress bar */
        --ascii-titles: off; /* off: default, on: use ascii font for titles at the start of a channel */
        --ascii-loader: cats; /* off: default, system24: use system24 ascii loader, cats: use cats loader */

        /* panel labels */
        --panel-labels: off; /* off: default, on: add labels to panels */
        --label-color: var(--text-muted); /* color of labels */
        --label-font-weight: 500; /* font weight of labels */
    }

    /* color options */
    :root {
        --colors: on; /* off: discord default colors, on: midnight custom colors */

        /* text colors */
        --text-0: var(--bg-4); /* text on colored elements */
        --text-1: hsl(38, 47%, 90%); /* bright text on colored elements */
        --text-2: var(--aqua); /* headings and important text */
        --text-3: #${base07}; /* normal text */
        --text-4: var(--aqua); /* icon buttons and channels */
        --text-5: var(--active); /* muted channels/chats and timestamps */

        /* background and dark colors */
        --bg-1: #${base02}; /* dark buttons when clicked */
        --bg-2: #${base01}; /* dark buttons */
        --bg-3: #${base01}; /* spacing, secondary elements */
        --bg-4: #${base00}; /* main background color */
        --hover: hsla(20, 3%, 40%, 0.1); /* channels and buttons when hovered */
        --active: #${base01}; /* channels and buttons when clicked or selected */
        --active-2: hsla(20, 3%, 40%, 0.3); /* extra state for transparent buttons */
        --message-hover: hsla(0, 0%, 0%, 0.1); /* messages when hovered */

        /* accent colors */
        --accent-1: var(--blue); /* links and other accent text */
        --accent-2: var(--blue); /* small accent elements */
        --accent-3: var(--blue); /* accent buttons */
        --accent-4: var(--purple); /* accent buttons when hovered */
        --accent-5: var(--purple); /* accent buttons when clicked */
        --accent-new: var(--aqua); /* stuff that's normally red like mute/deafen buttons */
        --mention: color-mix(in oklch, var(--aqua), transparent 90%); /* background of messages that mention you */
        --mention-hover: color-mix(in oklch, var(--aqua), transparent 95%); /* background of messages that mention you when hovered */
        --reply: color-mix(in oklch, var(--aqua), transparent 90%); /* background of messages that reply to you */
        --reply-hover: color-mix(in oklch, var(--aqua), transparent 95%); /* background of messages that reply to you when hovered */

        /* status indicator colors */
        --online: var(--green);
        --dnd: var(--red);
        --idle: var(--yellow);
        --streaming: var(--purple);
        --offline: var(--text-4);

        /* border colors */
        --border-light: var(--hover); /* general light border color */
        --border: var(--active); /* general normal border color */
        --border-hover: var(--yellow); /* border color of panels when hovered */
        --button-border: hsl(0, 0%, 100%, 0.1); /* neutral border color of buttons */

        /* base colors */
        --red: #${base08};
        --green: #${base0B};
        --blue: #${base0D};
        --yellow: #${base0A};
        --purple: #${base0E};
        --aqua: #${base0C}
    }
  '';
}
