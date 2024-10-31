import glaml.{
  type DocNode, DocNodeInt, DocNodeMap, DocNodeNil, DocNodeSeq, DocNodeStr,
}
import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import yodel/types.{type Properties}

pub fn parse(node: DocNode) -> Properties {
  parse_properties(node, "")
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
    DocNodeInt(value) -> dict.insert(dict.new(), prefix, int.to_string(value))
    DocNodeNil -> dict.insert(dict.new(), prefix, "nil")
  }
}

fn extract_key(node: DocNode) -> String {
  case node {
    DocNodeStr(value) -> value
    DocNodeInt(value) -> int.to_string(value)
    _ -> string.inspect(node)
  }
}
