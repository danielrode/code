// Author: Daniel Rode
// Dependencies: jq
// Made: 22 Dec 2020
// Updated: 26 Dec 2022


// This program will run and scrape the output of `swaymsg -t get_tree`
// collecting the focused window's title, app ID, ID, and backend (i.e.
// whether it is running on Xorg or Wayland). It will then print this
// information to stdout as well as display it via a notification sent through
// notify-send. The reason I have it print to stdout is so that the user can
// run it from the command line in the case that a very long window title
// obstructs information (given the limited space available per notification
// bubble). This script is designed to be run via a Sway keybinding.


// # RUNNING / BUILDING #
// To run/build this ./main.go source file:
//   cd THIS_DIRECTORY
//   go run ./main.go OR go build ./main.go
//
// If ./go.mod does file not exist, run:
//   go mod init sway-win-info
//   go mod tidy
//
// Then you should be able to successfully run/build ./main.go.
//
// Note: The "sway-win-info" argument passed to the go mod init command seems
//		 like it could be most anything else (as long as the name does not)
//		 match the name of some other dependency used by this code.


package main

import (
	"github.com/0xAX/notificator"
	"bytes"
	"fmt"
	"log"
	"os/exec"
	"strings"
)


var notify *notificator.Notificator


func run_cmd(exe string, args []string) string {
	//
	// Run a system executable and return the output.

	p := exec.Command(exe, args...)

	var out bytes.Buffer
	p.Stdout = &out

	err := p.Run()
	if err != nil {
		log.Fatal(err)
	}

	return out.String()
}


func run_cmd_with_input(exe string, args []string, input string) string {
	//
	// Run a system executable, passing it input, and return the output.

	p := exec.Command(exe, args...)
	p.Stdin = strings.NewReader(input)

	var out bytes.Buffer
	p.Stdout = &out

	err := p.Run()
	if err != nil {
		log.Fatal(err)
	}

	return out.String()
}


func main() {
	// Get the current sway container tree
	exe := "swaymsg"
	args := []string{"-t", "get_tree"}
	sway_tree := run_cmd(exe, args)

	// Get the title of the currently focused window (from the sway tree
	// output)
	exe = "jq"
	args = []string{
		".. | (.nodes? // empty)[] | select(.focused and .pid) | .name",
	}
	window_title := run_cmd_with_input(exe, args, sway_tree)
	window_title = strings.TrimSuffix(window_title, "\n")
    // Remove leading and trailing quote character
    window_title = window_title[1:len(window_title)-1]

	// Get the app ID and backend of the currently focused window (from the
    // sway tree output)
    //
    // Note: The value of the "shell" element for each container tells whether
    // the container's backend is Wayland or xwayland (X). While this is the
    // proper way, checking the app ID to guess the backend seems to work just
    // fine. X windows do not seem to implement app IDs, so if a container
    // does not have an app ID, assume it is running on X.
    //
    // Another note: an app ID is different from the container ID. The
	// container ID is a unique number that Sway assigns to each container;
	// the app ID is like the name of the program.
	exe = "jq"
	args = []string{
		".. | (.nodes? // empty)[] | select(.focused and .pid) | .app_id",
	}
	window_app_id := run_cmd_with_input(exe, args, sway_tree)
	var window_backend string
	if window_app_id == "null\n" {
		window_backend = "X"
        window_app_id = "N/A"
	} else {
		window_backend = "Wayland"
        window_app_id = strings.TrimSuffix(window_app_id, "\n")
        // Remove leading and trailing quote character
        window_app_id = window_app_id[1:len(window_app_id)-1]
	}

	// Get the ID of the currently focused window (from the sway tree
	// output)
	exe = "jq"
	args = []string{
		".. | (.nodes? // empty)[] | select(.focused and .pid) | .id",
	}
	window_id := run_cmd_with_input(exe, args, sway_tree)
	window_id = strings.TrimSuffix(window_id, "\n")

	// Format window information for notification message
	msg := fmt.Sprintf(
        "ID: %s\nAPP ID: %s\nBACKEND: %s",
		window_id,
        window_app_id,
		window_backend,
	)
	fmt.Println(window_title, msg)

	// Show notification
	notify = notificator.New(notificator.Options{
		// DefaultIcon: "icon/default.png",
		AppName: "Window Info Getter",
	})
	notify.Push(window_title, msg, "", "")
	// Example usage of 'notify':
	// notify.Push(
	// 	"title",
	// 	"text",
	// 	"/home/user/icon.png",
	// 	notificator.UR_CRITICAL
	// )
}
