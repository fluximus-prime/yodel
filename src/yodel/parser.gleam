import yodel/errors.{type ConfigError, ParseError, UnknownFormat}
import yodel/options.{type Format, Auto, Json, Toml, Yaml}
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/properties.{type Properties}

pub type Parser {
  Parser(name: String, parse: ParseFunction)
}

pub type ParseFunction =
  fn(String) -> Result(Properties, ConfigError)

pub fn parse(
  from content: String,
  with format: Format,
) -> Result(Properties, ConfigError) {
  case format {
    Json -> content |> parse_json
    Toml -> content |> parse_toml
    Yaml -> content |> parse_yaml
    Auto -> Error(ParseError(UnknownFormat))
  }
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
