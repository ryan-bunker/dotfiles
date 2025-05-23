#!/bin/sh

source "$CONFIG_DIR/icons.sh"

case "$1" in
"Terminal" | "Alacritty" | "kitty")
  RESULT=$ICON_TERM
	if grep -q "btop" <<< $2;
  then
	 RESULT=$ICON_CHART
	fi
	if grep -q "brew" <<< $2;
  then
	 RESULT=$ICON_PACKAGE
	fi
	if grep -q "nvim" <<< $2;
  then
	 RESULT=$ICON_DEV
	fi
	if grep -q "lazygit" <<< $2;
  then
	 RESULT=$ICON_GIT
	fi
	if grep -q "bat" <<< $2;
  then
	 RESULT=$ICON_NOTE
	fi
	if grep -q "tty-clock" <<< $2;
  then
	 RESULT=$ICON_CLOCK
	fi
	;;
"Finder")
	RESULT=$ICON_FILE
	;;
"Weather")
	RESULT=$ICON_WEATHER
	;;
"Clock")
	RESULT=$ICON_CLOCK
	;;
"Mail" | "Microsoft Outlook")
	RESULT=$ICON_MAIL
	;;
"Calendar")
	RESULT=$ICON_CALENDAR
	;;
"Calculator" | "Numi")
	RESULT=$ICON_CALC
	;;
"Maps" | "Find My")
	RESULT=$ICON_MAP
	;;
"Voice Memos")
	RESULT=$ICON_MICROPHONE
	;;
"Slack")
  RESULT=$ICON_APP_SLACK
  ;;
"Microsoft Teams (work or school)" | "Microsoft Teams")
  RESULT=$ICON_APP_TEAMS
  ;;
"Discord")
  RESULT=$ICON_APP_DISCORD
  ;;
"Messages" | "Telegram")
	RESULT=$ICON_CHAT
	;;
"FaceTime" | "zoom.us" | "Webex")
	RESULT=$ICON_VIDEOCHAT
	;;
"Notes" | "TextEdit" | "Stickies" | "Microsoft Word")
	RESULT=$ICON_NOTE
	;;
"Reminders" | "Microsoft OneNote" | "Logseq" | "Obsidian")
	RESULT=$ICON_LIST
	;;
"Photo Booth")
	RESULT=$ICON_CAMERA
	;;
"Safari")
  RESULT=$ICON_APP_SAFARI
  ;;
"Microsoft Edge")
  RESULT=$ICON_APP_EDGE
  ;;
"qutebrowser")
	RESULT=$ICON_WEB
	;;
"Beam" | "DuckDuckGo" | "Arc" | "Google Chrome" | "Firefox")
	RESULT=$ICON_WEB
	;;
"System Settings" | "System Information" | "TinkerTool")
	RESULT=$ICON_COG
	;;
"HOME")
	RESULT=$ICON_HOMEAUTOMATION
	;;
"Spotify")
  RESULT=$ICON_APP_SPOTIFY
  ;;
"Music")
	RESULT=$ICON_MUSIC
	;;
"Podcasts")
	RESULT=$ICON_PODCAST
	;;
"TV" | "QuickTime Player" | "VLC")
	RESULT=$ICON_PLAY
	;;
"Books")
	RESULT=$ICON_BOOK
	;;
"Xcode" | "Code" | "Neovide" | "IntelliJ IDEA")
	RESULT=$ICON_DEV
	;;
"Font Book" | "Dictionary")
	RESULT=$ICON_BOOKINFO
	;;
"Activity Monitor")
	RESULT=$ICON_CHART
	;;
"Disk Utility")
	RESULT=$ICON_DISK
	;;
"Screenshot" | "Preview")
	RESULT=$ICON_PREVIEW
	;;
"1Password")
	RESULT=$ICON_PASSKEY
	;;
"NordVPN")
	RESULT=$ICON_VPN
	;;
"Progressive Downloaded" | "Transmission")
	RESULT=$ICON_DOWNLOAD
	;;
"Airflow")
	RESULT=$ICON_CAST
	;;
"Microsoft Excel")
	RESULT=$ICON_TABLE
	;;
"Microsoft PowerPoint")
	RESULT=$ICON_PRESENT
	;;
"OneDrive")
	RESULT=$ICON_CLOUD
	;;
"Curve")
	RESULT=$ICON_PEN
	;;
"Microsoft Remote Desktop" | "VMware Fusion" | "UTM" | "Royal TSX")
	RESULT=$ICON_REMOTEDESKTOP
	;;
"App Store")
	RESULT=$ICON_STORE
	;;
"Dynamic wallpaper" | "Dynamic Wallpaper")
	RESULT=$ICON_WALLPAPER
	;;
"Beyond Compare")
	RESULT=$ICON_CODE_DIFF
	;;
"JetBrains Rider")
	RESULT=$ICON_CSHARP
	;;
"NetPad")
	RESULT="NP"
	;;
*)
	RESULT=[$1]
	;;
esac

echo $RESULT
