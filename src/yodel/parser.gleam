import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/options.{type Format, type YodelOptions, Auto, Json, Toml, Yaml} as cfg
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/types.{
  type ConfigError, type Input, type Properties, type YodelParser, Content, File,
  ParseError, UnknownFormat, YodelParser,
}
import yodel/utils

const parsers = [
  YodelParser("toml", toml.detect, toml.parse),
  YodelParser("json/yaml", yaml.detect, yaml.parse),
]

pub fn parse(
  from input: String,
  with options: YodelOptions,
) -> Result(Properties, ConfigError) {
  use props <- parse_input(input, options)
  props |> Ok
}

fn parse_input(
  input: String,
  options: YodelOptions,
  handler: fn(Properties) -> Result(Properties, ConfigError),
) -> Result(Properties, ConfigError) {
  use content <- get_content(input)

  case get_format(input, content, options) {
    Auto -> content |> parse_auto
    Json -> content |> parse_json
    Toml -> content |> parse_toml
    Yaml -> content |> parse_yaml
  }
  |> result.then(handler)
}

/// if the user specified a format, use it
/// otherwise, try to detect the format from the input
/// if that fails, try to detect the format from the content
/// and if that fails, as a last ditch effort...
/// we brute force our way through all the parsers until one works
fn get_format(input: String, content: String, options: YodelOptions) -> Format {
  case cfg.format(options) {
    Auto ->
      case input |> detect_input |> detect_format {
        Auto -> content |> detect_input |> detect_format
        format -> format
      }
    format -> format
  }
}

fn get_content(
  input: String,
  handler: fn(String) -> Result(Properties, ConfigError),
) -> Result(Properties, ConfigError) {
  case input |> detect_input {
    File(path) -> utils.read_file(path)
    Content(content) -> Ok(content)
  }
  |> result.then(handler)
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

fn try_parsers(
  parsers: List(YodelParser),
  content: String,
) -> Result(Properties, ConfigError) {
  list.fold(parsers, Error(ParseError(UnknownFormat)), fn(acc, parser) {
    case acc {
      Ok(props) -> Ok(props)
      Error(_) -> parser.parse(content)
    }
  })
}
