import gleam/list
import gleam/result
import gleam/string
import simplifile
import yodel/errors.{type ConfigError, ParseError, UnknownFormat}
import yodel/options.{type Format, type Options, Auto, Json, Toml, Yaml}
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/properties.{type Properties}
import yodel/types.{type Input, Content, File}
import yodel/utils

const parsers = [
  YodelParser("toml", toml.detect, toml.parse),
  YodelParser("json/yaml", yaml.detect, yaml.parse),
]

pub type YodelParser {
  YodelParser(name: String, detect: DetectFunction, parse: ParseFunction)
}

type ParserResult =
  Result(Properties, ConfigError)

pub type DetectFunction =
  fn(Input) -> Format

pub type ParseFunction =
  fn(String) -> ParserResult

pub fn parse(
  from input: String,
  with options: Options,
) -> Result(Properties, ConfigError) {
  use props <- parse_input(input, options)
  props |> Ok
}

fn parse_input(
  input: String,
  options: Options,
  handler: fn(Properties) -> Result(Properties, ConfigError),
) -> Result(Properties, ConfigError) {
  use content <- get_content(input)

  case get_format(input, content, options) {
    Json -> content |> parse_json
    Toml -> content |> parse_toml
    Yaml -> content |> parse_yaml
    Auto -> Error(ParseError(UnknownFormat))
  }
  |> result.then(handler)
}

/// if the user specified a format, use it
/// otherwise, try to detect the format from the input
/// if that fails, try to detect the format from the content
/// and if that fails, return `Auto` because we didn't figure it out
fn get_format(input: String, content: String, options: Options) -> Format {
  case options.get_format(options) {
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
  list.fold(parsers, options.Auto, fn(acc, parser) {
    case acc {
      options.Auto -> parser.detect(input)
      _ -> acc
    }
  })
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
