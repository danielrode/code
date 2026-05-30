// Author: Daniel Rode
// Name:
// Tags:
// Dependencies:
//     dependency1
//     dependency2
//     ...
// Version: *see 'version' variable below*
// Init:
// Updated: -


// Description:
// ...
// ...


package main


import (
	"github.com/bitfield/script"
		// Go will fail to build/run this file initially until the following
		// is run (in this directory):
		//   go mod init <THIS_PROGRAM_NAME>
		//   go mod tidy
		// Note that THIS_PROGRAM_NAME refers to the name of this (your) Go
		// project, not the dependency being imported.
)


// Variables
var (
    version = "4"
    cacheDirPath string
)


// Main
func main() {
	// example use of "script" library:
	script.Exec("ping -c 10 127.0.0.1").Stdout()
}



/*
TODO
- ...
*/
