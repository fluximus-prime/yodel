import gleam/list
import gleam/result
import gleam/string
import simplifile

import yodel/errors.{
  type ConfigError, FileError, FileNotFound, FilePermissionDenied, FileReadError,
}

pub type Input {
  File(path: String)
  Content(content: String)
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
