import glaml.{
  type DocNode, DocNodeBool, DocNodeFloat, DocNodeInt, DocNodeMap, DocNodeNil,
  DocNodeSeq, DocNodeStr,
}
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import yodel/errors.{
  type ConfigError, InvalidSyntax, Location, ParseError, SyntaxError,
}
import yodel/input.{type Input, Content, File}
import yodel/options.{type Format, Auto, Json, Yaml}
import yodel/path.{type Path}
import yodel/properties.{type Properties}

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
  let ext = input.get_extension_from_path(path)
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
    DocNodeStr(value) -> properties.string(path, value)
    DocNodeInt(value) -> properties.int(path, value)
    DocNodeFloat(value) -> properties.float(path, value)
    DocNodeBool(value) -> properties.bool(path, value)
    DocNodeNil -> properties.null(path)

    DocNodeMap(pairs) -> parse_map(pairs, path)
    DocNodeSeq(items) -> parse_seq(items, path)
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

fn parse_map(pairs: List(#(DocNode, DocNode)), path: Path) -> Properties {
  list.fold(pairs, properties.new(), fn(acc, pair) {
    let key = extract_key(pair.0)
    let path = path |> path.add_segment(key)
    let props = parse_properties(pair.1, path)
    properties.merge(acc, props)
  })
}

fn parse_seq(items: List(DocNode), path: Path) -> Properties {
  list.index_fold(items, properties.new(), fn(acc, item, index) {
    let path = path |> path.add_index(index)
    let props = parse_properties(item, path)
    properties.merge(acc, props)
  })
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
