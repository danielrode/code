// Author: Daniel Rode
// Name: Open
// Type: File Manager / Program Launcher
// Dependencies:
//   fzf
//   fd
// Version: *see 'version' variable below*
// Created: 02 Oct 2019

// Description:
// Opens things. Files are opened with a specified list of programs based on
// the file extension, URLs are opened in a web browser, and the contents of
// directories are recursively displayed to select from.

// I recommend creating a symbolic link to this program in place of your
// system's xdg-open script. However, note that this open program does not
// guarantee full compatibility with xdg-open.

// NOTE: Hidden files are not listed by default.
// NOTE: `swaymsg -t command exec...` strips env vars (leaving only ones main
// sway process knows about).

package main

import (
	"bufio"
	"bytes"
	"crypto/sha1"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	strs "strings"
	"time"
)

var print = fmt.Println

// Variables
const version = "36"

// Golang time format spec: https://go.dev/src/time/format.go
const lauoutMthDayHrMinS = "Jan 02 15:04:05"

var (
	cacheDirPath string
	findHidden   bool
	// runNvimInternally = false
)

// Functions
func getProgramByFiletype(path string) []string {
	// Get program I have designated to open the given filetype

	// My special-case exceptions for opening certain files with certain
	// programs (basically, for when I do not want to reconfigure XDG
	// settings).
	var pathLower = strs.ToLower(path)
	if isUrl(pathLower) {
		return []string{"firefox"}
	}
	switch filepath.Ext(pathLower) {
	case ".xopp":
		return []string{"xournalpp"}
	case ".pdf", ".djvu":
		return []string{"zathura"}
	case ".lyx":
		return []string{"lyx"}
	case ".png", ".jpg", ".jpeg", ".gif", ".svg", ".heic", ".webp":
		return []string{"imv-dir"}
	case ".mp4", ".wmv", ".m4v", ".webm", ".3gp", ".wav", ".3g2", ".avi",
		".mkv", ".mov", ".ogv", ".mpv", ".mts":
		return []string{"mpv", "--player-operation-mode=pseudo-gui"}
	case ".ogg", ".mp3", ".flac", ".aac", ".opus", ".m4a":
		return []string{"audacious"}
	case ".doc", ".docx", ".odt", ".ods", ".xlsx", ".xls", ".pptx":
		return []string{"libreoffice", "--nologo"}
	case ".csv", ".tsv":
		return []string{"gnumeric"}
	case ".xcf":
		return []string{"gimp"}
	case ".zim":
		return []string{"zim"}
	case ".kdenlive":
		return []string{"kdenlive"}
	case ".html":
		return []string{"firefox"}
	case ".qgz", ".qgs", ".gpkg", ".shp", ".las", ".laz", ".geojson",
		".vrt", ".copc.laz", ".tif", ".tiff", ".fgb", ".vpc", ".kml":
		// return []string{"flatpak", "run", "org.qgis.qgis"}
		return []string{os.Getenv("HOME") + "/code/bin/qgis"}
	default:
		return []string{"foot-helix"}
	}
}

func openPaths(pathsList []string) {
	if len(pathsList) == 0 {
		return
	}

	var program = getProgramByFiletype(pathsList[0])
	var pathBatch = []string{pathsList[0]}
	if len(pathsList) == 1 {
		swayExec(program, pathBatch)
		return
	}

	var programPrev = strs.Join(program, " ")
	var index = 1
	for _, path := range pathsList[1:] {
		var program = getProgramByFiletype(path)
		if strs.Join(program, " ") == programPrev {
			pathBatch = append(pathBatch, path)
		} else {
			break
		}
		index += 1
	}
	swayExec(program, pathBatch)
	if index <= len(pathsList) {
		openPaths(pathsList[index:])
	}
}

func shaStr(msg string) string {
	// SHA1 hash a string and return the hash

	var h = sha1.New()
	h.Write([]byte(msg))

	return fmt.Sprintf("%x", h.Sum(nil))
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func isDirectory(path string) bool {
	var fileInfo, err = os.Stat(path)
	if err != nil {
		return false
	}

	return fileInfo.IsDir()
}

func isUrl(str string) bool {
	if strs.HasPrefix(str, "http://") {
		return true
	} else if strs.HasPrefix(str, "https://") {
		return true
	} else {
		return false
	}
}

func timestamp() string {
	// Golang time format spec: https://go.dev/src/time/format.go
	return time.Now().Format(lauoutMthDayHrMinS)
}

func escapePath(path string) string {
	path = strs.ReplaceAll(path, "\\", "\\\\")
	path = strs.ReplaceAll(path, " ", "\\ ")
	path = strs.ReplaceAll(path, " -", " \\-")
	path = strs.ReplaceAll(path, "!", "\\!")
	path = strs.ReplaceAll(path, "\"", "\\\"")
	path = strs.ReplaceAll(path, "#", "\\#")
	path = strs.ReplaceAll(path, "$", "\\$")
	path = strs.ReplaceAll(path, "&", "\\&")
	path = strs.ReplaceAll(path, "'", "\\'")
	path = strs.ReplaceAll(path, "(", "\\(")
	path = strs.ReplaceAll(path, ")", "\\)")
	path = strs.ReplaceAll(path, "*", "\\*")
	path = strs.ReplaceAll(path, ",", "\\,")
	path = strs.ReplaceAll(path, ";", "\\;")
	path = strs.ReplaceAll(path, "<", "\\<")
	path = strs.ReplaceAll(path, "=", "\\=")
	path = strs.ReplaceAll(path, ">", "\\>")
	path = strs.ReplaceAll(path, "?", "\\?")
	path = strs.ReplaceAll(path, "[", "\\[")
	path = strs.ReplaceAll(path, "]", "\\]")
	path = strs.ReplaceAll(path, "^", "\\^")
	path = strs.ReplaceAll(path, "`", "\\`")
	path = strs.ReplaceAll(path, "{", "\\{")
	path = strs.ReplaceAll(path, "|", "\\|")
	path = strs.ReplaceAll(path, "}", "\\}")
	path = strs.ReplaceAll(path, "~", "\\~")

	return path
}

func absPath(path string) string {
	// Prepend PWD if path not already anchored to root directory ('/')
	if strs.HasPrefix(path, "/") {
		return path
	} else {
		var cwd, _ = os.Getwd()
		return cwd + "/" + path
	}
}

func swayExec(program []string, pathsList []string) {
	// Open file path(s) with specific program via Sway socket
	var escapedPathsList []string
	for _, path := range pathsList {
		if isUrl(path) {
			path = escapePath(path)
		} else {
			path = escapePath(absPath(path))
		}
		escapedPathsList = append(escapedPathsList, path)
	}
	print("Opening with '" + strs.Join(program, " ") + "':")
	for _, path := range escapedPathsList {
		print(path)
	}
	var execParameters = []string{"-t", "command", "exec", "--"}
	execParameters = append(execParameters, program...)
	for _, path := range escapedPathsList {
		execParameters = append(execParameters, path)
	}
	var cmd = exec.Command("swaymsg", execParameters...)
	cmd.Run()
}

func findCmd(dirs []string) *exec.Cmd {
	var args = []string{
		// "--one-file-system",
		"--exclude", "*~", // exclude backup files
	}
	if findHidden {
		args = append(args, "--hidden")
	}
	args = append(args, ".")
	args = append(args, dirs...)
	return exec.Command("fd", args...)
}

type fzfQueryState struct {
	query            string
	refresh          bool
	nth              int
	parentDir        string
	resultsTimestamp string
}

func fzfCmd(s fzfQueryState) *exec.Cmd {
	return exec.Command("fzf",
		"--multi",
		"--reverse",
		"--border",
		"--cycle",
		"--tiebreak=end,length,index",
		"--prompt=file: ",
		"--inline-info",
		"--keep-right",
		"--delimiter=.",
		"--with-nth="+strconv.Itoa(s.nth)+"..",
		"--query="+s.query,
		"--header=Press F5 to refresh the list"+
			"\nRefreshed: "+s.resultsTimestamp+
			"\nParent: "+s.parentDir,
		"--bind", "f5:execute(echo '///REFRESH///{q}')+abort",
		"--bind", "ctrl-space:execute(echo {} &)+clear-query",
		"--bind", "ctrl-U:clear-query+top",
	)
}

func findToFzf(dirs []string, s fzfQueryState) ([]string, fzfQueryState) {
	// Take a list of dirs, pass to fd (find), then pass results to fzf

	// Setup fd (find) command
	var find = findCmd(dirs)
	var findOut, _ = find.StdoutPipe()

	// Tell fzf to strip leading parent path if just one directory is selected
	if len(dirs) == 1 {
		s.parentDir = dirs[0]
		s.nth = len(strs.TrimRight(dirs[0], "/")) + 2
	} else {
		s.parentDir = "-"
	}

	// Set cache refresh timestamp to pass to fzf
	s.resultsTimestamp = timestamp()

	// Setup fzf command
	var fzf = fzfCmd(s)
	var fzfOutput bytes.Buffer
	fzf.Stdout = &fzfOutput
	fzf.Stderr = os.Stderr
	var fzfIn, _ = fzf.StdinPipe()

	// Run fd (find) and fzf and pass output from fd to fzf
	find.Start()
	fzf.Start()
	// Save fd (find) output to RAM (in buffer) and also send it to fzf stdin
	var findOutput bytes.Buffer
	io.Copy(io.MultiWriter(&findOutput, fzfIn), findOut)

	find.Wait()
	findOut.Close()
	fzf.Wait()
	fzfIn.Close()

	var paths = strs.Split(fzfOutput.String(), "\n") // Paths selected in fzf
	paths = paths[:len(paths)-1]                     // Drop trailing '\n'

	// If user presses F5 in fzf (to refresh), relay this information to the
	// calling function
	s.query = ""
	s.refresh = false
	if len(paths) > 0 {
		if strs.HasPrefix(paths[0], "///REFRESH///") {
			s.query = paths[0][13:]
			s.refresh = true
		}
	}

	return paths, s
}

func cacheToFzf(dirs []string, s fzfQueryState) ([]string, fzfQueryState) {
	// Tell fzf to strip leading parent path if just one directory is selected
	if len(dirs) == 1 {
		s.parentDir = dirs[0]
		s.nth = len(strs.TrimRight(dirs[0], "/")) + 2
	} else {
		s.parentDir = "-"
	}

	// dirsSignature is a sha1 string that represents a unique set of
	// directories. These identifiers are used to save and recall cache files
	// for each specific set of directories passed to this program when cache
	// mode is active.
	var dirsCopy = make([]string, len(dirs))
	sort.Strings(dirsCopy)
	var dirsSignature = strs.Join(dirs, "\x00")
	dirsSignature = shaStr(dirsSignature)

	// Open cache file that corresponds to given dirsSignature. If it does not
	// exist, create it.
	var cacheFilePath = cacheDirPath + "/" + dirsSignature
	var cacheFile, err = os.OpenFile(cacheFilePath, os.O_RDWR, 0600)
	if err != nil { // If cache file does not exist...
		s.refresh = true

		// Create cache file
		cacheFile, err = os.Create(cacheFilePath)
		check(err)
		err = os.Chmod(cacheFilePath, 0600)
		check(err)
	}
	defer cacheFile.Close()

	// Get/set cache refresh timestamp to pass to fzf
	if s.refresh {
		s.resultsTimestamp = timestamp()
	} else {
		var fileStats, err = cacheFile.Stat()
		check(err)
		s.resultsTimestamp = fileStats.ModTime().Format(lauoutMthDayHrMinS)
	}

	var find = findCmd(dirs)
	var findOut, _ = find.StdoutPipe()
	var fzfOutput bytes.Buffer
	var fzf = fzfCmd(s)
	fzf.Stdout = &fzfOutput
	fzf.Stderr = os.Stderr
	var fzfIn, _ = fzf.StdinPipe()
	fzf.Start()
	if s.refresh {
		// Pipe list of file(s) from fd(find) to both cache and fzf.
		// io.MultiWriter works similar to Unix `tee` command.
		find.Start()
		io.Copy(io.MultiWriter(cacheFile, fzfIn), findOut)
	} else {
		// Pipe list of file(s) from cache to fzf
		io.Copy(fzfIn, cacheFile)
	}

	find.Wait()
	findOut.Close()
	fzfIn.Close()
	fzf.Wait()
	var paths = strs.Split(fzfOutput.String(), "\n") // Paths selected in fzf
	paths = paths[:len(paths)-1]                     // Drop trailing '\n'

	// If user presses F5 in fzf (to refresh), relay this information to the
	// calling function
	s.query = ""
	s.refresh = false
	if len(paths) > 0 {
		if strs.HasPrefix(paths[0], "///REFRESH///") {
			s.query = paths[0][13:]
			s.refresh = true
		}
	}

	return paths, s
}

func siftPaths(pathsList ...string) ([]string, []string) {
	// Sort out directory paths
	var dirPaths []string
	var nonDirPaths []string
	for _, path := range pathsList {
		if isDirectory(path) {
			dirPaths = append(dirPaths, path)
		} else {
			nonDirPaths = append(nonDirPaths, path)
		}
	}

	return dirPaths, nonDirPaths
}

// Hijack XDG methods
func ls(path string) []os.DirEntry {
	var fileList, err = os.ReadDir(path)
	check(err)

	return fileList

	// To get paths as strings from fileList, call .Name() on the slice's
	// elements.
}

func cat(path string) string {
	var fileContent, err = os.ReadFile(path)
	check(err)

	return string(fileContent)
}

func uniq(items []string) []string {
	// Remove all duplicate items from a slice of strings

	var uniqueMap = make(map[string]bool)
	for _, str := range items {
		if _, value := uniqueMap[str]; !value {
			uniqueMap[str] = true
		}
	}
	var uniqueList = []string{}
	for key := range uniqueMap {
		uniqueList = append(uniqueList, key)
	}
	return uniqueList
}

func getMimes() []string {
	// Return an array of all mime types listed under /usr/share/applications

	var dirPath = "/usr/share/applications/"
	var mimeTypes []string
	for _, child := range ls(dirPath) {
		if !child.IsDir() {
			var path = dirPath + child.Name() // Full file path
			var r, _ = regexp.Compile("\nMimeType=.*")
			var match = r.FindString(cat(path))
			if len(match) > 0 {
				mimeTypes = append(
					mimeTypes,
					strs.Split(match[10:len(match)-1], ";")...,
				)
			}
		}
	}

	return mimeTypes
}

func hijackXdg() {
	// See comment under '--hijack-xdg' flag below

	// Retrieve list of mime types from system
	var mimeTypes = getMimes()

	// Get/make XDG config path
	var xdgConfigPath, _ = os.LookupEnv("XDG_CONFIG_HOME")
	if xdgConfigPath == "" {
		xdgConfigPath = os.Getenv("HOME") + "/.config/"
	}
	os.MkdirAll(xdgConfigPath, os.ModePerm) // Similar to 'mkdir -p'

	// Get/make XDG share and .decktop files path
	var xdgSharePath, _ = os.LookupEnv("XDG_DATA_HOME")
	if xdgSharePath == "" {
		xdgSharePath = os.Getenv("HOME") + "/.local/share/"
	}
	var xdgDesktopsPath = xdgSharePath + "/applications"
	os.MkdirAll(xdgDesktopsPath, os.ModePerm) // Similar to 'mkdir -p'

	// Write o.desktop
	print("Create .desktop file for `o`...")
	var f, err = os.Create(xdgSharePath + "/applications/o.desktop")
	check(err)
	f.WriteString("[Desktop Entry]\nType=Application\nExec=o %F\n")
	f.Close()

	// Write XDG defaults config file (setting `o` as the default opener for
	// everything)
	print("Configure XDG to use o.desktop to open everything...")
	var blob = "[Default Applications]\n"
	for _, m := range mimeTypes {
		blob = blob + m + "=o.desktop\n"
	}
	f, err = os.Create(xdgConfigPath + "/mimeapps.list")
	check(err)
	defer f.Close()
	f.WriteString(blob)

	// Inform user how to finish the process
	print("Done")
	print("Now just run the following to complete the process:")
	print("sudo ln -sf /bin/xdg-open \"$DCV_CODE_PATH/bin/o\"")
}

func is_pipe_in() bool {
	// Check if program's stdin is connected to a pipe

	var fi, _ = os.Stdin.Stat()
	if (fi.Mode() & os.ModeCharDevice) == 0 {
		return true
	} else {
		return false
	}
}

// Main
func main() {

	// Process input
	var paths []string
	if is_pipe_in() {
		var s = bufio.NewScanner(os.Stdin)
		for s.Scan() {
			paths = append(paths, s.Text())
		}
	}

	// Process arguments
	var cacheMode = false
	findHidden = false
	for _, arg := range os.Args[1:] {
		if strs.HasPrefix(arg, "-") {
			switch arg {
			case "-c", "--cache-mode":
				cacheMode = true
			case "-.", "--hidden":
				// Instruct fd (find) to list hidden files
				findHidden = true
			// case "--nnn":
			// If file would be opened in nvim, run nvim locally in the
			// current terminal (that way, opening a text file in nnn
			// will open that text file in nvim in that same terminal
			// window, and exiting nvim will take the user back to nnn)
			// runNvimInternally = true
			case "-i", "--hijack-xdg":
				// Hijack XDG-open/mime so that attempts by the system or
				// other applications to open files with those will ridirect
				// to `o`. This is accomplished by replacing xdg-ogen
				// executable with a link to `o` executable and the creating
				// o.desktop and setting it as the default for all mime types
				// listed under /usr/share/applications. Note that if this
				// flag if provided, nothing else is run (the program exits
				// after hijack is complete).
				print("Hijacking XDG so `o` is used to open files...")
				hijackXdg()
				os.Exit(0)
			case "--version":
				print("Version: " + version)
				return // Exit
			default:
				var msg = "error: Unsupported flag " + arg + "\n"
				os.Stderr.WriteString(msg)
				// defers will not be run when using os.Exit
				os.Exit(1)
			}
		} else {
			paths = append(paths, arg)
		}
	}

	// Cache mode
	var dirsProcFunc = findToFzf
	if cacheMode {
		var homePath = os.Getenv("HOME")
		var cacheHomePath, _ = os.LookupEnv("XDG_CACHE_HOME")
		if cacheHomePath == "" {
			cacheHomePath = homePath + "/.cache/daniel_rode_code/"
		} else {
			cacheHomePath = cacheHomePath + "/daniel_rode_code/"
		}
		os.MkdirAll(cacheHomePath, os.ModePerm) // Similar to 'mkdir -p'

		// Locate cache store:
		// Get tmp cache dir path. If o-cache.link file exists, read it. If
		// not, create it and tmp dir and point the link to the tmp dir.
		// If path pointed to in o-cache.link file does not exist, create tmp
		// cache dir path and point o-cache.link path to it.
		var cacheLinkPath = cacheHomePath + "/o-cache.link"
		var err error
		cacheDirPath, err = os.Readlink(cacheLinkPath)
		if (err != nil) || (!isDirectory(cacheDirPath)) {
			cacheDirPath, _ = os.MkdirTemp("/tmp", "")
			os.Remove(cacheLinkPath)
			os.Symlink(cacheDirPath, cacheLinkPath)
		}

		dirsProcFunc = cacheToFzf
	}

	// If no path is given, display a recursive list of files from the current
	// working directory
	if len(paths) == 0 {
		paths = []string{"."}
	}

	// Process provided paths
	var dirPaths []string
	var nonDirPathsList []string
	var s = fzfQueryState{
		query:            "",
		refresh:          false,
		nth:              1, // Have fzf strip n leading directories
		parentDir:        "-",
		resultsTimestamp: "",
	}
	for {
		// Open all provided non-directory paths, then pass directory paths
		// to fd (find) whose results will pass to fzf. If the user chooses
		// to refresh within fzf (by pressing F5), the directory paths will
		// be searched again, but the non-directory paths (which were already)
		// opened will not be opened again.

		dirPaths, nonDirPathsList = siftPaths(paths...)

		// Open list of provided non-directory paths
		openPaths(nonDirPathsList)

		// Parse provided directories' contents via fd (find) and fzf
		if len(dirPaths) > 0 {
			for {
				paths, s = dirsProcFunc(dirPaths, s)
				if !s.refresh {
					break
				}
			}
		} else {
			// If user does not select any entries in fzf, then exit
			return
		}
	}
}

/*
TODO
- Put commonly opened files toward the top of the results.
- Support determining target application via file mime type.
- Support file URIs (i.e. file://host/path/...).
- Support reading list of newline separated paths/URLs from stdin.
- Trim long lines that extend past ruler.
- Allow user to navigate back up to parent directory.
- Consider merging cacheToFzf and findToFzf functions (they have both been
  refactored to use io.Copy instead of goroutines--which fixed the incomplete
  results problem--so the functions might be able to be merged into one
  function that uses if statements to accommodate cache mode).
- Make shift-enter in fzf navigate to the parent directory of the selected
  path.
- Add help text and flags (-? -h --help)
- Provide --choice flag to show user list of options for handling the given
  file. Each filetype should have a list of programs or scripts or menus that
  can open/process that type of file. If the --choice flag is not provided, o
  should just use the first option in that list of items. For instance, if I
  run `o archive.zip`, I might want to list the archive content or extract it.
  Actually, now that I say that, I think it makes more sense to just have o
  call a different script for all archive file types, and that other script
  will handle asking me whether I want to list, extract, or add to archive.
*/
