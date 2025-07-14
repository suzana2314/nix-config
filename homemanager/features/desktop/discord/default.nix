{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ vesktop ];

  xdg.configFile."vesktop/themes/suz-gruvbox.theme.css".text = ''
    /**
     * @name suz gruvbox
     * @description A dark and gruvy, rounded discord theme.
     * @author refact0r, suz
     * @version 2025.01
     * @invite nz87hXyvcy
     * @website https://github.com/refact0r/midnight-discord
     * @source https://github.com/refact0r/midnight-discord/blob/master/midnight.theme.css
     * @authorId 508863359777505290
     * @authorLink https://www.refact0r.dev
    */

    /* IMPORTANT: make sure to enable dark mode in discord settings for the theme to apply properly!!! */

    @import url("https://refact0r.github.io/midnight-discord/build/midnight.css");

    /* customize things here */
    :root {
      /* font, change to 'gg sans' for default discord font*/
      --font: "${config.fontProfiles.monospace.name}";

      /* top left corner text */
      --corner-text: "suz";

      /* color of status indicators and window controls */
      --online-indicator: #b8bb26; /* change to #23a55a for default green */
      --dnd-indicator: #fb4934; /* change to #f13f43 for default red */
      --idle-indicator: #fabd2f; /* change to #f0b232 for default yellow */
      --streaming-indicator: hsl(
        260,
        60%,
        60%
      ); /* change to #593695 for default purple */

      /* accent colors */
      --accent-1: #89b482; /* links */
      --accent-2: #89b482; /* general unread/mention elements */
      --accent-3: #83a598; /* accent buttons */
      --accent-4: #8ec07c; /* accent buttons when hovered */
      --accent-5: #83a598; /* accent buttons when clicked */
      --mention: color-mix(in oklch, #89b482, transparent 90%); /* mentions & mention messages */
      --mention-hover: color-mix(in oklch, #89b482, transparent 95%); /* mentions & mention messages when hovered */

      /* text colors */
      --text-0: #1d2021; /* text on colored elements */
      --text-1: #ddc7a1; /* other normally white text */
      --text-2: #8ec07c; /* headings and important text */
      --text-3: #ddc7a1; /* normal text */
      --text-4: #d4be98; /* icon buttons and channels */
      --text-5: #928374; /* muted channels/chats and timestamps */

      /* background and dark colors */
      --bg-1: #504945; /* dark buttons when clicked */
      --bg-2: #665c54; /* dark buttons */
      --bg-3: #282828; /* spacing, secondary elements */
      --bg-4: #1d2021; /* main background color */
      --hover: #504945; /* channels and buttons when hovered */
      --active: #3c3836; /* channels and buttons when clicked or selected */
      --message-hover: hsla(220, 0%, 0%, 0.1); /* messages when hovered */

      /* amount of spacing and padding */
      --spacing: 10px;

      /* animations */
      /* ALL ANIMATIONS CAN BE DISABLED WITH REDUCED MOTION IN DISCORD SETTINGS */
      --list-item-transition: 0.2s ease; /* channels/members/settings hover transition */
      --unread-bar-transition: 0.2s ease; /* unread bar moving into view transition */
      --moon-spin-transition: 0.4s ease; /* moon icon spin */
      --icon-spin-transition: 1s ease; /* round icon button spin (settings, emoji, etc.) */

      /* corner roundness (border-radius) */
      --roundness-xl: 10px; /* roundness of big panel outer corners */
      --roundness-l: 10px; /* popout panels */
      --roundness-m: 10px; /* smaller panels, images, embeds */
      --roundness-s: 10px; /* members, settings inputs */
      --roundness-xs: 10px; /* channels, buttons */
      --roundness-xxs: 10px; /* searchbar, small elements */

      --border-light: var(--bg-4); /* general light border color */
      --border: var(--bg-3); /* general normal border color */
      --border-hover: var(--bg-3); /* border color of panels when hovered */
      --button-border: hsl(220, 0%, 100%, 0.1); /* neutral border color of buttons */

      /* direct messages moon icon */
      /* change to block to show, none to hide */
      --discord-icon: none; /* discord icon */
      --moon-icon: block; /* moon icon */
      --moon-icon-url: url("https://upload.wikimedia.org/wikipedia/commons/4/48/Duck_-_Delapouite_-_white_-_game-icons.svg"); /* custom icon url */
      --moon-icon-size: auto;

      /* filter uncolorable elements to fit theme */
      /* (just set to none, they're too much work to configure) */
      --login-bg-filter: saturate(0.3) hue-rotate(-15deg) brightness(0.4); /* login background artwork */
      --green-to-accent-3-filter: hue-rotate(56deg) saturate(1.43); /* add friend page explore icon */
      --blurple-to-accent-3-filter: hue-rotate(304deg) saturate(0.84)
        brightness(1.2); /* add friend page school icon */

      /* nav buttons */
      --windows-nav: none;
      --custom-nav: block;
    }
    body {
      container-name: body;
      --font: "${config.fontProfiles.monospace.name}";

      /* sizes */
      --gap: 12px; /* spacing between panels */
      --divider-thickness: 4px; /* thickness of unread messages divider and highlighted message borders */
    }

  '';
}
