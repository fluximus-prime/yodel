import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/context
import yodel/options.{type YodelOptions} as cfg
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/resolver
import yodel/types.{
  type ConfigError, type InputType, type Properties, type YodelContext,
  type YodelParser, Content, EmptyConfig, File, FileError, FileNotFound,
  FilePermissionDenied, FileReadError, InvalidConfig, ParseError, UnknownFormat,
  ValidationError, YodelParser,
}

const parsers = [
  YodelParser("toml", toml.parse), YodelParser("json/yaml", yaml.parse),
]

pub fn parse(
  from input: String,
  with options: YodelOptions,
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
  options: YodelOptions,
) -> Result(YodelContext, ConfigError) {
  use content <- read_file(path)
  parse_content(content, options)
}

fn parse_content(
  content: String,
  options: YodelOptions,
) -> Result(YodelContext, ConfigError) {
  case options.format {
    cfg.Auto -> parse_auto(content)
    cfg.Json -> parse_json(content)
    cfg.Toml -> parse_toml(content)
    cfg.Yaml -> parse_yaml(content)
  }
  |> result.then(fn(props) { validate_and_resolve(props, options) })
}

fn parse_auto(content: String) -> Result(Properties, ConfigError) {
  try_parsers(parsers, content)
}

fn parse_json(content: String) -> Result(Properties, ConfigError) {
  yaml.parse(content)
}

fn parse_toml(content: String) -> Result(Properties, ConfigError) {
  toml.parse(content)
}

fn parse_yaml(content: String) -> Result(Properties, ConfigError) {
  yaml.parse(content)
}

fn validate_and_resolve(
  props: Properties,
  options: YodelOptions,
) -> Result(YodelContext, ConfigError) {
  case validate(props) {
    Ok(validated) -> {
      case cfg.resolve(options) {
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
  parsers: List(YodelParser),
  content: String,
) -> Result(Properties, ConfigError) {
  list.fold(parsers, Error(ParseError(UnknownFormat)), fn(acc, parser) {
    io.debug("Trying parser: " <> parser.name)
    case acc {
      Ok(props) -> {
        io.debug("Parser succeeded, skipping remaining parsers")
        Ok(props)
      }
      Error(_) -> parser.parse(content)
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
