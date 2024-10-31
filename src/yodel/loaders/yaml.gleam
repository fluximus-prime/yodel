import glaml
import gleam/dict
import gleam/result
import simplifile
import yodel/context
import yodel/errors
import yodel/parsers/property
import yodel/parsers/resolver
import yodel/types.{
  type Properties, type YodelContext, type YodelError, InvalidContent,
  InvalidPath,
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
      let props =
        glaml.doc_node(doc)
        |> property.parse_properties
        |> resolver.resolve_properties

      case is_valid(props) {
        True -> Ok(context.new(props))
        False -> Error(InvalidContent("Invalid config data"))
      }
    }
    Error(err) -> {
      Error(InvalidContent(err |> errors.doc_error_to_string))
    }
  }
}

fn is_valid(props: Properties) -> Bool {
  case dict.size(props) {
    // prevent empty configs
    0 -> False
    1 -> {
      // prevent broken configs
      case dict.get(props, "") {
        Ok(_) -> False
        Error(_) -> True
      }
    }
    _ -> True
  }
}
