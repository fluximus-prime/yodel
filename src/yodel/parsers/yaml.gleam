import glaml.{
  type DocNode, DocNodeBool, DocNodeFloat, DocNodeInt, DocNodeMap, DocNodeNil,
  DocNodeSeq, DocNodeStr,
}
import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import yodel/options.{type Format, Auto, Json, Yaml}
import yodel/path.{type Path}
import yodel/types.{
  type ConfigError, type Input, type Properties, Content, File, InvalidSyntax,
  Location, ParseError, SyntaxError,
}
import yodel/utils

const known_extensions = [
  #("json", ["json", "jsn", "json5", "jsonc"]), #("yaml", ["yaml", "yml"]),
]

pub fn detect(input: Input) -> Format {
  case input {
    File(path) -> {
      detect_format_from_path(path)
    }
    Content(content) -> {
      detect_format_from_content(content)
    }
  }
}

fn detect_format_from_path(path: String) -> Format {
  let ext = utils.get_extension_from_path(path)
  case
    list.find(known_extensions, fn(entry) {
      let #(_, exts) = entry
      list.contains(exts, ext)
    })
  {
    Ok(#("json", _)) -> Json
    Ok(#("yaml", _)) -> Yaml
    _ -> {
      Auto
    }
  }
}

fn detect_format_from_content(content: String) -> Format {
  let trimmed = string.trim(content)
  case detect_json(trimmed) {
    True -> options.Json
    False ->
      case detect_yaml(trimmed) {
        True -> options.Yaml
        False -> {
          Auto
        }
      }
  }
}

fn detect_json(content: String) -> Bool {
  { string.starts_with(content, "{") || string.starts_with(content, "[") }
  && { string.ends_with(content, "}") || string.ends_with(content, "]") }
  && string.contains(content, ":")
}

fn detect_yaml(content: String) -> Bool {
  {
    string.starts_with(content, "---")
    || string.contains(content, ":")
    || string.contains(content, "- ")
  }
  && { !string.starts_with(content, "{") && !string.starts_with(content, "[") }
}

pub fn parse(from string: String) -> Result(Properties, ConfigError) {
  case glaml.parse_string(string) {
    Ok(doc) -> glaml.doc_node(doc) |> parse_properties(path.new()) |> Ok
    Error(err) -> Error(map_glaml_error(err))
  }
}

fn parse_properties(node: DocNode, path: Path) -> Properties {
  case node {
    DocNodeMap(pairs) -> {
      list.fold(pairs, dict.new(), fn(acc, pair) {
        let key = extract_key(pair.0)
        let path = path |> path.segment(key)
        let props = parse_properties(pair.1, path)
        dict.merge(acc, props)
      })
    }

    DocNodeSeq(items) -> {
      list.index_fold(items, dict.new(), fn(acc, item, index) {
        let path = path |> path.index(index)
        let props = parse_properties(item, path)
        dict.merge(acc, props)
      })
    }

    DocNodeStr(value) -> dict.insert(dict.new(), path.format(path), value)
    DocNodeBool(value) ->
      dict.insert(dict.new(), path.format(path), bool.to_string(value))
    DocNodeInt(value) ->
      dict.insert(dict.new(), path.format(path), int.to_string(value))
    DocNodeFloat(value) ->
      dict.insert(dict.new(), path.format(path), float.to_string(value))
    DocNodeNil -> dict.insert(dict.new(), path.format(path), "nil")
  }
}

fn extract_key(node: DocNode) -> String {
  case node {
    DocNodeStr(value) -> value
    DocNodeInt(value) -> int.to_string(value)
    DocNodeFloat(value) -> float.to_string(value)
    _ -> string.inspect(node)
  }
}

fn map_glaml_error(error: glaml.DocError) -> ConfigError {
  let glaml.DocError(msg, #(line, col)) = error
  ParseError(
    InvalidSyntax(SyntaxError(
      format: "Json/Yaml",
      location: Location(line, col),
      message: msg,
    )),
  )
}
