import glaml
import yodel/context
import yodel/errors
import yodel/parsers/placeholders
import yodel/parsers/properties
import yodel/types.{type YodelContext, type YodelError, InvalidContent}
import yodel/utils

pub fn load_file(from path: String) -> Result(YodelContext, YodelError) {
  use string <- utils.read_file(path)
  load_string(string)
}

pub fn load_string(from string: String) -> Result(YodelContext, YodelError) {
  case glaml.parse_string(string) {
    Ok(doc) -> {
      let props =
        glaml.doc_node(doc)
        |> properties.parse
        |> placeholders.resolve

      case utils.is_valid(props) {
        True -> Ok(context.new(props))
        False -> Error(InvalidContent("Invalid config data"))
      }
    }
    Error(err) -> {
      Error(InvalidContent(err |> errors.doc_error_to_string))
    }
  }
}
