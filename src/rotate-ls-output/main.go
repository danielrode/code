// Author: Daniel Rode
// Created: 29 Dec 2019
// Updated: 07 Jan 2020


// Given a filename as input, this program will list the files within the
// parent directory of the file given in sorted order. This list of files
// will be processed and rearranged so that the file following the initially
// specified file will be printed first. The files following that one will
// then be printed in order. Once the end of the list is reached, lines
// will then be printed from the beginning of the list until the initially
// specified file is reached. The initially specified file is never printed.
//
// This program was created to aid in my use of 'imv' (the image viewer). When
// imv is pointed to a directory, it displays images out of order. This
// program provides a list of ordered paths to pass to imv so that it will
// allow the user to navigate images with imv in a sorted order, while
// allowing the user to specify a specific image that may be in the middle
// of the list for them to view first, and then to browse in order from that
// image onward.
//
// It is my hope that imv will be fixed soon, and display images in sorted
// order when pointed to a directory.

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func path_is_file(path string) bool {
	fileInfo, err := os.Stat(path)
	if err != nil {
		fmt.Println(err)
		fmt.Println(
			"warning: There was an error while reading the above path's" +
				" stats. Path shall be skipped.",
		)
		return false
	}
	mode := fileInfo.Mode()
	return mode.IsRegular()
}

func path_not_hidden(path string) bool {
	if strings.HasPrefix(path, ".") {
		return false
	} else {
		return true
	}
}

func main() {
	// Read command line argument (input)
	var arg = os.Args[1]

	var file_parent_dir = filepath.Dir(arg)
	// Set the file name the user inputted as the line to match during
	// iteration
	var file_base = filepath.Base(arg)

	// Compile list of files contained in the directory of the path the user
	// entered
	var files, _ = filepath.Glob(file_parent_dir + "/*")

	// Iterate over list of files.
	// Print from (but not including) the matching line to the end
	var print_paths = false
	for _, path := range files {
		if print_paths {
			// Only print path if it is a non-hidden file (and not a directory)
			if path_is_file(path) && path_not_hidden(path) {
				fmt.Println(path)
			}
		}

		if file_base == filepath.Base(path) {
			print_paths = true
		}
	}

	// Iterate over list of files.
	// Print from the beginning up to the matching line
	print_paths = true
	for _, path := range files {
		if file_base == filepath.Base(path) {
			break
		}

		// Only print path if it is a non-hidden file (and not a directory)
		if path_is_file(path) && path_not_hidden(path) {
			fmt.Println(path)
		}
	}

}
