import gleam/dict.{type Dict}
import yodel/options.{type Format}

pub type Properties =
  Dict(String, String)

pub type YodelContext {
  YodelContext(props: Properties)
}

pub type YodelParser {
  YodelParser(
    name: String,
    detect: fn(Input) -> Format,
    parse: fn(String) -> Result(Properties, ConfigError),
  )
}

pub type Input {
  File(path: String)
  Content(content: String)
}

pub type ConfigError {
  FileError(FileError)
  ParseError(ParseError)
  ResolverError(ResolverError)
  ValidationError(ValidationError)
}

pub type GetError {
  KeyNotFound(key: String)
  TypeError(key: String, expected: GetType, got: String)
}

pub type GetType {
  BoolValue
  FloatValue
  IntValue
  StringValue
}

pub type FileError {
  FileNotFound(path: String)
  FilePermissionDenied(path: String)
  FileReadError(details: String)
}

pub type ParseError {
  InvalidSyntax(SyntaxError)
  InvalidStructure(details: String)
  UnknownFormat
}

pub type SyntaxError {
  SyntaxError(format: String, location: Location, message: String)
}

pub type Location {
  Location(line: Int, column: Int)
}

pub type ResolverError {
  EnvVarNotFound(key: String)
}

pub type ValidationError {
  EmptyConfig
  InvalidConfig(details: String)
}
