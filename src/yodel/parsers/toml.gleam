import birl
import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import tom.{
  type Date, type DateTime, type Time, type Toml, Array, ArrayOfTables, Bool,
  Date, DateTime, Float, Infinity, InlineTable, Int, Nan, String, Table, Time,
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
    True -> options.Toml
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
    True -> options.Toml
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
    Int(i) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        int.to_string(i),
      )
    Float(f) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        float.to_string(f),
      )
    Infinity(_) ->
      properties.insert(properties.new(), path.path_to_string(path), "nil")
    Nan(_) ->
      properties.insert(properties.new(), path.path_to_string(path), "nil")
    Bool(b) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        bool.to_string(b),
      )
    String(s) ->
      properties.insert(properties.new(), path.path_to_string(path), s)
    Date(d) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        format_date(d),
      )
    Time(t) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        format_time(t),
      )
    DateTime(dt) ->
      properties.insert(
        properties.new(),
        path.path_to_string(path),
        format_datetime(dt),
      )
    Array(array) -> {
      list.index_fold(array, properties.new(), fn(acc, item, index) {
        let path = path |> path.add_index(index)
        let props = parse_value(item, path)
        properties.merge(acc, props)
      })
    }
    ArrayOfTables(tables) -> {
      list.index_fold(tables, properties.new(), fn(acc, table, index) {
        let path = path |> path.add_index(index)
        let props = parse_properties(table, path)
        properties.merge(acc, props)
      })
    }
    Table(table) -> parse_properties(table, path)
    InlineTable(table) -> parse_properties(table, path)
  }
}

fn format_datetime(dt: DateTime) -> String {
  let d = format_date(dt.date)
  let t = format_time(dt.time)
  let f = d <> "T" <> t
  case birl.from_naive(f) {
    Ok(dt) -> birl.to_naive_date_string(dt)
    Error(_) -> f
  }
}

fn format_date(date: Date) -> String {
  let s =
    int.to_string(date.year)
    <> "-"
    <> int.to_string(date.month)
    <> "-"
    <> int.to_string(date.day)
  case birl.from_naive(s) {
    Ok(d) -> birl.to_date_string(d)
    Error(_) -> s
  }
}

fn format_time(time: Time) -> String {
  let s =
    int.to_string(time.hour)
    <> ":"
    <> int.to_string(time.minute)
    <> ":"
    <> int.to_string(time.second)
    <> ":"
    <> int.to_string(time.millisecond)
  case birl.from_naive(s) {
    Ok(t) -> birl.to_time_string(t)
    Error(_) -> s
  }
}

fn map_tom_error(error: tom.ParseError) -> ConfigError {
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
