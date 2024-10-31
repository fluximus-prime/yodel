import glaml
import gleam/result
import simplifile
import yodel/errors
import yodel/parsers/property
import yodel/parsers/resolver
import yodel/types.{
  type YodelContext, type YodelError, InvalidContent, InvalidPath, YodelContext,
}

pub fn load_file(from path: String) -> Result(YodelContext, YodelError) {
  simplifile.read(path)
  |> result.map_error(fn(err) {
    InvalidPath(err |> errors.file_error_to_string)
  })
  |> result.try(fn(string) { load_string(string) })
}

pub fn load_string(from string: String) -> Result(YodelContext, YodelError) {
  case glaml.parse_string(string) {
    Ok(doc) -> {
      glaml.doc_node(doc)
      |> property.parse_properties
      |> resolver.resolve_properties
      |> YodelContext
      |> Ok
    }
    Error(err) -> {
      Error(InvalidContent(err |> errors.doc_error_to_string))
    }
  }
}
