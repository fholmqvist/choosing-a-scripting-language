package main

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"path/filepath"
	"strings"
)

type FoldersWithFiles map[string][]string

func (f FoldersWithFiles) Keys() []string {
	files := make([]string, 0, len(f))
	for _, folder := range f {
		files = append(files, folder...)
	}
	return files
}

func main() {
	files := loadFiles("../../testing/")
	r, err := http.Get("http://localhost:8080")
	if err != nil {
		panic(err)
	}
	defer r.Body.Close()
	var serverFiles FoldersWithFiles
	json.NewDecoder(r.Body).Decode(&serverFiles)
	newFiles := findNewFiles(files, serverFiles)
	keys := newFiles.Keys()
	expected := 3507
	if len(keys) != expected {
		panic(fmt.Sprintf("expected %v, got %v", expected, len(keys)))
	}
}

func loadFiles(path string) FoldersWithFiles {
	files := FoldersWithFiles{}
	filepath.Walk(path, func(path string, info fs.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return nil
		}
		parts := strings.Split(path, "/")
		folder := parts[len(parts)-2]
		name := info.Name()
		if !strings.Contains(name, ".zip") || !strings.Contains(name, "_") {
			return nil
		}
		if _, ok := files[folder]; !ok {
			files[folder] = []string{}
		}
		files[folder] = append(files[folder], name)
		return nil
	})
	return files
}

func findNewFiles(localFiles, serverFiles FoldersWithFiles) FoldersWithFiles {
	newFiles := FoldersWithFiles{}
	for folder, files := range localFiles {
		if _, ok := serverFiles[folder]; !ok {
			newFiles[folder] = files
			continue
		}
		for _, file := range files {
			var found bool
			for _, serverFile := range serverFiles[folder] {
				if file == serverFile {
					found = true
					break
				}
			}
			if found {
				continue
			}
			if _, ok := newFiles[folder]; !ok {
				newFiles[folder] = []string{}
			}
			newFiles[folder] = append(newFiles[folder], file)
		}
	}
	return newFiles
}
