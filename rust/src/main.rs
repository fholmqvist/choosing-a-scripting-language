use std::fs;
use std::{collections::HashMap, path::Path};

fn load_files(path: &Path) -> HashMap<String, Vec<String>> {
    let mut files = HashMap::<String, Vec<String>>::new();
    let mut stack = vec![path.to_path_buf()];

    while let Some(curr) = stack.pop() {
        if let Ok(entries) = fs::read_dir(&curr) {
            for entry in entries.filter_map(|e| e.ok()) {
                let path = entry.path();
                let parent = path.parent().unwrap().to_str().unwrap().to_owned();
                let full_path = path.clone().as_path().to_str().unwrap().to_owned();
                let metadata = fs::metadata(&path).unwrap();

                if metadata.is_dir() {
                    stack.push(path);
                } else {
                    files.entry(parent).or_insert(Vec::new()).push(full_path);
                }
            }
        }
    }

    files
}

fn main() {
    let files = load_files(Path::new("../testing"));
    dbg!(files);
}
