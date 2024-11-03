import gleam/io
import gleam/list
import gleam/string
import simplifile
import yodel/context
import yodel/errors
import yodel/loaders/toml
import yodel/loaders/yaml
import yodel/resolver
import yodel/types.{
  type Properties, type YodelContext, type YodelError, InvalidContent,
  InvalidPath,
}
import yodel/utils

pub fn load(from string: String) -> Result(YodelContext, YodelError) {
  let trimmed = string.trim(string)

  case simplifile.is_file(trimmed) {
    Ok(True) -> {
      io.debug("Input is a file")
      load_file(trimmed)
    }
    _ -> {
      io.debug("Input is not a file, attempting to load as a string")
      load_string(trimmed)
    }
  }
}

fn load_file(path: String) -> Result(YodelContext, YodelError) {
  io.debug("Loading file: " <> path)
  case simplifile.read(path) {
    Ok(content) -> load_string(content)
    Error(err) -> Error(InvalidPath(errors.file_error_to_string(err)))
  }
}

fn load_string(content: String) -> Result(YodelContext, YodelError) {
  let parsers = [#("toml", toml.parse), #("yaml/json", yaml.parse)]

  io.debug("Trying to parse config data: " <> content)

  case try_parsers(parsers, content) {
    Ok(props) -> {
      case utils.is_valid(props) {
        True -> props |> resolver.resolve_properties |> context.new |> Ok
        False -> {
          io.debug("Invalid config data")
          Error(InvalidContent("Invalid config data"))
        }
      }
    }
    Error(err) -> Error(err)
  }
}

fn try_parsers(
  parsers: List(#(String, fn(String) -> Result(Properties, YodelError))),
  content: String,
) -> Result(Properties, YodelError) {
  list.fold(
    parsers,
    Error(InvalidContent("Invalid config content")),
    fn(acc, parser) {
      case acc {
        Ok(props) -> {
          io.debug("Parser succeeded, skipping remaining parsers")
          Ok(props)
        }
        Error(_) -> {
          io.debug("Trying parser: " <> parser.0)
          parser.1(content)
        }
      }
    },
  )
}
