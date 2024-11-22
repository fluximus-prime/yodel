import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/types.{
  type ConfigError, type Path, type Properties, type Value, FileError,
  FileNotFound, FilePermissionDenied, FileReadError,
}

pub fn get_extension_from_path(path: String) -> String {
  case
    path |> string.trim |> string.lowercase |> string.split(".") |> list.last
  {
    Ok(ext) -> string.lowercase(ext)
    _ -> ""
  }
}

pub fn read_file(from path: String) -> Result(String, ConfigError) {
  simplifile.read(path)
  |> result.map_error(fn(err) { map_simplifile_error(err) })
}

fn map_simplifile_error(error: simplifile.FileError) -> ConfigError {
  FileError(case error {
    simplifile.Eacces -> FilePermissionDenied(simplifile.describe_error(error))
    simplifile.Enoent -> FileNotFound(simplifile.describe_error(error))
    _ -> FileReadError(simplifile.describe_error(error))
  })
}

pub fn new_properties(path: Path, value: Value) -> Properties {
  dict.insert(dict.new(), path, value)
}
