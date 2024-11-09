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
import yodel/types.{
  type ConfigError, type Properties, InvalidStructure, InvalidSyntax, Location,
  ParseError, SyntaxError,
}

pub fn parse(from content: String) -> Result(Properties, ConfigError) {
  case tom.parse(content) {
    Ok(doc) -> parse_properties(doc, "") |> Ok
    Error(err) -> Error(map_tom_error(err))
  }
}

fn parse_properties(doc: Dict(String, Toml), prefix: String) -> Properties {
  dict.fold(doc, dict.new(), fn(acc, key, value) {
    let new_prefix = case prefix {
      "" -> key
      _ -> prefix <> "." <> key
    }
    let props = parse_value(value, new_prefix)
    dict.merge(acc, props)
  })
}

fn parse_value(value: Toml, prefix: String) -> Properties {
  case value {
    Int(i) -> dict.insert(dict.new(), prefix, int.to_string(i))
    Float(f) -> dict.insert(dict.new(), prefix, float.to_string(f))
    Infinity(_) -> dict.insert(dict.new(), prefix, "nil")
    Nan(_) -> dict.insert(dict.new(), prefix, "nil")
    Bool(b) -> dict.insert(dict.new(), prefix, bool.to_string(b))
    String(s) -> dict.insert(dict.new(), prefix, s)
    Date(d) -> dict.insert(dict.new(), prefix, format_date(d))
    Time(t) -> dict.insert(dict.new(), prefix, format_time(t))
    DateTime(dt) -> dict.insert(dict.new(), prefix, format_datetime(dt))
    Array(array) -> {
      list.index_fold(array, dict.new(), fn(acc, item, index) {
        let new_prefix = prefix <> "[" <> int.to_string(index) <> "]"
        let props = parse_value(item, new_prefix)
        dict.merge(acc, props)
      })
    }
    ArrayOfTables(tables) -> {
      list.index_fold(tables, dict.new(), fn(acc, table, index) {
        let new_prefix = prefix <> "[" <> int.to_string(index) <> "]"
        let props = parse_properties(table, new_prefix)
        dict.merge(acc, props)
      })
    }
    Table(table) -> parse_properties(table, prefix)
    InlineTable(table) -> parse_properties(table, prefix)
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
