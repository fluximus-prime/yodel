import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import tom.{
  type Date, type DateTime, type Offset, type ParseError, type Time, type Toml,
  Array, ArrayOfTables, Bool, Date, DateTime, Float, Infinity, InlineTable, Int,
  Local, Nan, Negative, Offset, Positive, String, Table, Time,
}
import yodel/errors.{
  type ConfigError, InvalidStructure, InvalidSyntax, Location, ParseError,
  SyntaxError,
}
import yodel/input.{type Input, Content, File}
import yodel/options.{type Format, Auto, Toml}
import yodel/path.{type Path}
import yodel/properties.{type Properties}

const known_extensions = ["toml", "tml"]

pub fn detect(input: Input) -> Format {
  case input {
    File(path) -> detect_format_from_path(path)
    Content(content) -> detect_format_from_content(content)
  }
}

fn detect_format_from_path(path: String) -> Format {
  let ext = input.get_extension_from_path(path)
  case list.contains(known_extensions, ext) {
    True -> Toml
    False -> Auto
  }
}

fn detect_format_from_content(content: String) -> Format {
  let trimmed = string.trim(content)
  case
    string.contains(trimmed, "=")
    && !string.contains(trimmed, ": ")
    && !string.starts_with(trimmed, "---")
  {
    True -> Toml
    False -> Auto
  }
}

pub fn parse(from content: String) -> Result(Properties, ConfigError) {
  case tom.parse(content) {
    Ok(doc) -> parse_properties(doc, path.new()) |> Ok
    Error(err) -> Error(map_tom_error(err))
  }
}

fn parse_properties(doc: Dict(String, Toml), path: Path) -> Properties {
  dict.fold(doc, properties.new(), fn(acc, key, value) {
    let path = path |> path.add_segment(key)
    let props = parse_value(value, path)
    properties.merge(acc, props)
  })
}

fn parse_value(value: Toml, path: Path) -> Properties {
  case value {
    String(value) -> properties.string(path, value)
    Int(value) -> properties.int(path, value)
    Float(value) -> properties.float(path, value)
    Bool(value) -> properties.bool(path, value)

    Infinity(_) -> properties.null(path)
    Nan(_) -> properties.null(path)

    Date(value) -> properties.string(path, date_to_string(value))
    Time(value) -> properties.string(path, time_to_string(value))
    DateTime(value) -> properties.string(path, date_time_to_string(value))

    Array(array) -> parse_array(array, path)
    ArrayOfTables(tables) -> parse_array_of_tables(tables, path)
    Table(table) -> parse_properties(table, path)
    InlineTable(table) -> parse_properties(table, path)
  }
}

fn date_time_to_string(datetime: DateTime) -> String {
  let date = date_to_string(datetime.date)
  let time = time_to_string(datetime.time)
  let offset = offset_to_string(datetime.offset)
  date <> "T" <> time <> offset
}

fn date_to_string(date: Date) -> String {
  int.to_string(date.year)
  <> "-"
  <> int.to_string(date.month)
  <> "-"
  <> int.to_string(date.day)
}

fn time_to_string(time: Time) -> String {
  int.to_string(time.hour)
  <> ":"
  <> int.to_string(time.minute)
  <> ":"
  <> int.to_string(time.second)
  <> ":"
  <> int.to_string(time.millisecond)
}

fn offset_to_string(offset: Offset) -> String {
  case offset {
    Local -> ""
    Offset(direction, hours, minutes) -> {
      let sign = case direction {
        Positive -> "+"
        Negative -> "-"
      }
      sign <> int.to_string(hours) <> ":" <> int.to_string(minutes)
    }
  }
}

fn parse_array(array: List(Toml), path: Path) -> Properties {
  list.index_fold(array, properties.new(), fn(acc, item, index) {
    let path = path |> path.add_index(index)
    let props = parse_value(item, path)
    properties.merge(acc, props)
  })
}

fn parse_array_of_tables(
  tables: List(Dict(String, Toml)),
  path: Path,
) -> Properties {
  list.index_fold(tables, properties.new(), fn(acc, table, index) {
    let path = path |> path.add_index(index)
    let props = parse_properties(table, path)
    properties.merge(acc, props)
  })
}

fn map_tom_error(error: ParseError) -> ConfigError {
  ParseError(case error {
    tom.Unexpected(got, expected) ->
      InvalidSyntax(SyntaxError(
        format: "Toml",
        location: Location(0, 0),
        message: "Expected " <> expected <> ", but got " <> got,
      ))
    tom.KeyAlreadyInUse(key) ->
      InvalidStructure("Key already in use: " <> string.join(key, "."))
  })
}
