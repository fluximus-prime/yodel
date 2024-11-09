import gleam/dict.{type Dict}
import gleam/int

pub type Properties =
  Dict(String, String)

pub type YodelContext {
  YodelContext(props: Properties)
}

pub type ParseOptions {
  ParseOptions(resolve: Bool)
}

pub type InputType {
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

pub fn format_config_error(error: ConfigError) -> String {
  case error {
    FileError(file_error) -> format_file_error(file_error)
    ParseError(parse_error) -> format_parse_error(parse_error)
    ResolverError(resolve_error) -> format_resolve_error(resolve_error)
    ValidationError(validation_error) ->
      format_validation_error(validation_error)
  }
}

fn format_file_error(error: FileError) -> String {
  case error {
    FileNotFound(path) -> "File not found: " <> path
    FilePermissionDenied(path) -> "Permission denied: " <> path
    FileReadError(details) -> "Error reading file: " <> details
  }
}

fn format_parse_error(error: ParseError) -> String {
  case error {
    InvalidSyntax(error) -> format_syntax_error(error)
    InvalidStructure(details) -> details
    UnknownFormat -> "Unable to determine config format"
  }
}

fn format_syntax_error(error: SyntaxError) -> String {
  let SyntaxError(format, location, message) = error
  let Location(line, column) = location
  "Syntax error in "
  <> format
  <> " at line "
  <> int.to_string(line)
  <> ", column "
  <> int.to_string(column)
  <> ": "
  <> message
}

fn format_resolve_error(error: ResolverError) -> String {
  case error {
    EnvVarNotFound(key) -> "Environment variable not found: " <> key
  }
}

fn format_validation_error(error: ValidationError) -> String {
  case error {
    EmptyConfig -> "Empty config"
    InvalidConfig(details) -> "Invalid config: " <> details
  }
}
