import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/context
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/resolver
import yodel/types.{
  type ConfigError, type InputType, type ParseOptions, type Properties,
  type YodelContext, Content, EmptyConfig, File, FileError, FileNotFound,
  FilePermissionDenied, FileReadError, InvalidConfig, ParseError, UnknownFormat,
  ValidationError,
}

pub fn parse(
  from input: String,
  with options: ParseOptions,
) -> Result(YodelContext, ConfigError) {
  case detect_input_type(input) {
    File(path) -> parse_file(path, options)
    Content(content) -> parse_content(content, options)
  }
}

fn detect_input_type(input: String) -> InputType {
  case string.trim(input) |> simplifile.is_file {
    Ok(True) -> File(input)
    _ -> Content(input)
  }
}

fn parse_file(
  path: String,
  options: ParseOptions,
) -> Result(YodelContext, ConfigError) {
  use content <- read_file(path)
  parse_content(content, options)
}

fn parse_content(
  content: String,
  options: ParseOptions,
) -> Result(YodelContext, ConfigError) {
  let parsers = [#("toml", toml.parse), #("json/yaml", yaml.parse)]
  case try_parsers(parsers, content) {
    Ok(props) -> validate_and_resolve(props, options)
    Error(err) -> Error(err)
  }
}

fn validate_and_resolve(
  props: Properties,
  options: ParseOptions,
) -> Result(YodelContext, ConfigError) {
  case validate(props) {
    Ok(validated) -> {
      case options.resolve {
        True -> validated |> resolve |> context.new |> Ok
        False -> validated |> context.new |> Ok
      }
    }
    Error(err) -> Error(err)
  }
}

fn validate(props: Properties) -> Result(Properties, ConfigError) {
  case dict.size(props) {
    0 -> EmptyConfig |> ValidationError |> Error
    1 -> {
      case dict.get(props, "") {
        Ok(_) ->
          InvalidConfig("Invalid config content") |> ValidationError |> Error
        Error(_) -> props |> Ok
      }
    }
    _ -> props |> Ok
  }
}

fn resolve(props: Properties) -> Properties {
  resolver.resolve_properties(props)
}

fn try_parsers(
  parsers: List(#(String, fn(String) -> Result(Properties, ConfigError))),
  content: String,
) -> Result(Properties, ConfigError) {
  list.fold(parsers, Error(ParseError(UnknownFormat)), fn(acc, parser) {
    io.debug("Trying parser: " <> parser.0)
    case acc {
      Ok(props) -> {
        io.debug("Parser succeeded, skipping remaining parsers")
        Ok(props)
      }
      Error(_) -> parser.1(content)
    }
  })
}

fn read_file(
  from path: String,
  then handler: fn(String) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  simplifile.read(path)
  |> result.map_error(fn(err) { map_simplifile_error(err) })
  |> result.then(handler)
}

fn map_simplifile_error(error: simplifile.FileError) -> ConfigError {
  FileError(case error {
    simplifile.Eacces -> FilePermissionDenied(simplifile.describe_error(error))
    simplifile.Enoent -> FileNotFound(simplifile.describe_error(error))
    _ -> FileReadError(simplifile.describe_error(error))
  })
}
