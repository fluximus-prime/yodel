import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/context
import yodel/options.{type Format, type YodelOptions, Auto, Json, Toml, Yaml} as cfg
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/resolver
import yodel/types.{
  type ConfigError, type Input, type Properties, type YodelContext,
  type YodelParser, Content, EmptyConfig, File, InvalidConfig, ParseError,
  UnknownFormat, ValidationError, YodelParser,
}
import yodel/utils

const parsers = [
  YodelParser("toml", toml.detect, toml.parse),
  YodelParser("json/yaml", yaml.detect, yaml.parse),
]

pub fn parse(
  from input: String,
  with options: YodelOptions,
) -> Result(YodelContext, ConfigError) {
  use content <- get_content(input)
  use props <- parse_content(content)
  validate_and_resolve(props, options)
}

fn detect_input(input: String) -> Input {
  case string.trim(input) |> simplifile.is_file {
    Ok(True) -> File(input)
    _ -> Content(input)
  }
}

fn detect_format(input: Input) -> Format {
  list.fold(parsers, cfg.Auto, fn(acc, parser) {
    case acc {
      cfg.Auto -> parser.detect(input)
      _ -> acc
    }
  })
}

fn get_content(
  input: String,
  handler: fn(String) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  case input |> detect_input {
    File(path) -> utils.read_file(path)
    Content(content) -> Ok(content)
  }
  |> result.then(handler)
}

fn parse_content(
  content: String,
  handler: fn(Properties) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  case content |> detect_input |> detect_format {
    Auto -> parse_auto(content)
    Json -> parse_json(content)
    Toml -> parse_toml(content)
    Yaml -> parse_yaml(content)
  }
  |> result.then(handler)
}

fn parse_auto(content: String) -> Result(Properties, ConfigError) {
  try_parsers(parsers, content)
}

fn parse_json(content: String) -> Result(Properties, ConfigError) {
  // the yaml parser also handles json
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
