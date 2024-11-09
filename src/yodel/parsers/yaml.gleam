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
import yodel/types.{
  type ConfigError, type Properties, InvalidSyntax, Location, ParseError,
  SyntaxError,
}

pub fn parse(from string: String) -> Result(Properties, ConfigError) {
  case glaml.parse_string(string) {
    Ok(doc) -> glaml.doc_node(doc) |> parse_properties("") |> Ok
    Error(err) -> Error(map_glaml_error(err))
  }
}

fn parse_properties(node: DocNode, prefix: String) -> Properties {
  case node {
    DocNodeMap(pairs) -> {
      list.fold(pairs, dict.new(), fn(acc, pair) {
        let key = extract_key(pair.0)
        let new_prefix = case prefix {
          "" -> key
          _ -> prefix <> "." <> key
        }
        let props = parse_properties(pair.1, new_prefix)
        dict.merge(acc, props)
      })
    }

    DocNodeSeq(items) -> {
      list.index_fold(items, dict.new(), fn(acc, item, index) {
        let new_prefix = prefix <> "[" <> int.to_string(index) <> "]"
        let props = parse_properties(item, new_prefix)
        dict.merge(acc, props)
      })
    }

    DocNodeStr(value) -> dict.insert(dict.new(), prefix, value)
    DocNodeBool(value) -> dict.insert(dict.new(), prefix, bool.to_string(value))
    DocNodeInt(value) -> dict.insert(dict.new(), prefix, int.to_string(value))
    DocNodeFloat(value) ->
      dict.insert(dict.new(), prefix, float.to_string(value))
    DocNodeNil -> dict.insert(dict.new(), prefix, "nil")
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
