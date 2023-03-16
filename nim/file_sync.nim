import os, tables, strutils, std/[asyncdispatch, httpclient], json

type FolderWithFiles = Table[string, seq[string]]

proc keys(f: FolderWithFiles): seq[string] =
    var res: seq[string]
    for k in f.keys:
        res.add(k)
    return res

proc load_files(path: string, f: var FolderWithFiles) =
    for kind, file in walkDir(path):
        if $kind == "pcDir":
            load_files(file, f)
        var (path, name, ext) = file.splitFile()
        if ext != ".zip":
            continue
        if not name.contains("_"):
            continue
        var folder = path.split("/")[1]
        discard f.hasKeyOrPut(folder, newSeq[string]())
        f[folder].add(name & ext)

proc find_new_files(local_files, server_files: FolderWithFiles): FolderWithFiles =
    var new_files: FolderWithFiles
    for folder, files in local_files:
        if not server_files.hasKey(folder):
            new_files[folder] = files
            continue
        for file in files:
            var found = false
            for server_file in server_files[folder]:
                if file == server_file:
                    found = true
                    break
            if found:
                continue
            discard new_files.hasKeyOrPut(folder, newSeq[string]())
            new_files[folder].add(file)
    return new_files

when isMainModule:
    var local_files: FolderWithFiles
    load_files("./files", local_files)
    var client = newAsyncHttpClient()
    let response = waitFor client.getContent("http://localhost:8080/")
    let server_files = to(parseJson response, FolderWithFiles)
    let new_files = find_new_files(local_files, server_files)
    assert(new_files.keys().len() == 1)
