import gleam/int
import yodel/types.{
  type ConfigError, type FileError, type ParseError, type ResolverError,
  type SyntaxError, type ValidationError, EmptyConfig, FileError, FileNotFound,
  FilePermissionDenied, FileReadError, InvalidConfig, InvalidStructure,
  InvalidSyntax, Location, NoPlaceholderFound, ParseError, RegexError,
  ResolverError, SyntaxError, UnknownFormat, UnresolvedPlaceholder,
  ValidationError,
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
    UnresolvedPlaceholder(placeholder, value) ->
      "Could not resolve placeholder '"
      <> placeholder
      <> "' in value \""
      <> value
      <> "\""
    RegexError(details) -> "Regex error: " <> details
    NoPlaceholderFound -> "No placeholder found"
  }
}

fn format_validation_error(error: ValidationError) -> String {
  case error {
    EmptyConfig -> "Empty config"
    InvalidConfig(details) -> "Invalid config: " <> details
  }
}
