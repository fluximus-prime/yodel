import gleam/dict.{type Dict}
import yodel/options.{type Format}

pub type Properties =
  Dict(Path, Value)

pub type Property =
  #(Path, Value)

pub type PropertyType {
  Path(Path)
  Value(Value)
}

pub type Path =
  String

pub type Value =
  String

pub type YodelContext {
  YodelContext(props: Properties)
}

pub type YodelParser {
  YodelParser(name: String, detect: DetectFunction, parse: ParseFunction)
}

pub type DetectFunction =
  fn(Input) -> Format

pub type ParseFunction =
  fn(String) -> Result(Properties, ConfigError)

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
  PathNotFound(path: String)
  TypeError(path: String, expected: GetType, got: String)
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
  UnresolvedPlaceholder(placeholder: String, value: String)
  RegexError(details: String)
  NoPlaceholderFound
}

pub type ValidationError {
  EmptyConfig
  InvalidConfig(details: String)
}
