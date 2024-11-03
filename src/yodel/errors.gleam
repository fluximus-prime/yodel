import glaml.{type DocError, DocError}
import gleam/int
import gleam/string
import simplifile.{type FileError}
import tom.{type ParseError, KeyAlreadyInUse, Unexpected}

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

pub fn parse_error_to_string(error: ParseError) -> String {
  case error {
    Unexpected(got, expected) -> "Got " <> got <> ", expected " <> expected
    KeyAlreadyInUse(key) -> "Key already in use: " <> string.join(key, ".")
  }
}
