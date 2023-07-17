require "http"
require "json"

def load_files(path)
  files = Hash(String, Array(String)).new

  Dir.entries(path).each do |entry|
    next if entry == "." || entry == ".."

    full_path = File.join(path, entry)
    if File.directory?(full_path)
      files = files.merge(load_files(full_path))
    end

    next if File.extname(full_path) != ".zip" || !full_path.includes?("_")

    if !files.has_key?(entry)
      files[entry] = Array(String).new
    end

    files[entry] << full_path
  end

  files
end

def find_new_files(local_files, files_on_server)
  new_files = Hash(String, Array(String)).new

  local_files.each do |folder, files|
    if !files_on_server.has_key?(folder)
      new_files[folder] = files
      next
    end

    files.each do |file|
      file_already_exists = files_on_server[folder].any? do |server_file|
        file == server_file
      end

      next if file_already_exists

      if !new_files.has_key?(folder)
        new_files[folder] = [] of String
      end

      new_files[folder] << file
    end
  end

  new_files
end

local_files = load_files("../testing")

res = HTTP::Client.get("http://localhost:8080")
raise "Request failed with #{res.status_code}" unless res.status_code == 200

json = JSON.parse(res.body)

# Error: expected argument #1 to 'JSON::Lexer.new' to be IO or String, not JSON::Any
files_from_server = Hash(String, Array(String)).from_json(json)

new_files = find_new_files(local_files, files_from_server)
puts new_files.size
