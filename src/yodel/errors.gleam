import glaml.{type DocError, DocError}
import gleam/int
import simplifile.{type FileError}

pub fn doc_error_to_string(error: DocError) -> String {
  let DocError(msg, loc) = error
  let #(line, col) = loc
  "Error at line "
  <> int.to_string(line)
  <> ","
  <> int.to_string(col)
  <> ": "
  <> msg
}

pub fn file_error_to_string(error: FileError) -> String {
  simplifile.describe_error(error)
}
