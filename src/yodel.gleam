import envoy
import glaml.{
  type DocError, type DocNode, DocError, DocNodeInt, DocNodeMap, DocNodeNil,
  DocNodeSeq, DocNodeStr,
}
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/regex.{type Regex}
import gleam/result
import gleam/string
import simplifile.{type FileError}

pub type YodelContext {
  YodelContext(props: Properties)
}

pub type Properties =
  Dict(String, String)

pub type YodelError {
  InvalidPath(error: String)
  InvalidContent(error: String)
}

pub fn load_file(from file_path: String) -> Result(YodelContext, YodelError) {
  simplifile.read(file_path)
  |> result.map_error(fn(err) { InvalidPath(err |> file_error_to_string) })
  |> result.try(load_string)
}

pub fn load_string(from config: String) -> Result(YodelContext, YodelError) {
  case glaml.parse_string(config) {
    Ok(doc) -> {
      glaml.doc_node(doc)
      |> parse_properties
      |> resolve_properties
      |> YodelContext
      |> Ok
    }
    Error(err) -> {
      Error(InvalidContent(err |> doc_error_to_string))
    }
  }
}

fn resolve_properties(on props: Properties) -> Properties {
  let assert Ok(pattern) = regex.from_string("\\$\\{([^}]+)\\}")
  dict.fold(props, dict.new(), fn(acc, key, value) {
    let resolved = resolve_property(#(key, value), pattern)
    dict.merge(acc, resolved)
  })
}

fn resolve_property(
  on property: #(String, String),
  with pattern: Regex,
) -> Properties {
  let #(key, value) = property
  case
    regex.split(pattern, value) |> string.join("") |> string.split_once(":")
  {
    Ok(#(var, default)) -> {
      case envoy.get(var) {
        Ok(resolved) -> {
          dict.from_list([
            #(key, string.replace(value, "${" <> var <> "}", resolved)),
          ])
        }
        Error(_) -> dict.from_list([#(key, default)])
      }
    }
    Error(_) -> dict.from_list([#(key, value)])
  }
}

fn parse_properties(node: DocNode) -> Properties {
  parse(node, "")
}

fn parse(node: DocNode, prefix: String) -> Properties {
  case node {
    DocNodeMap(pairs) -> {
      list.fold(pairs, dict.new(), fn(acc, pair) {
        let key = extract_key(pair.0)
        let new_prefix = case prefix {
          "" -> key
          _ -> prefix <> "." <> key
        }
        let props = parse(pair.1, new_prefix)
        dict.merge(acc, props)
      })
    }

    DocNodeSeq(items) -> {
      list.index_fold(items, dict.new(), fn(acc, item, index) {
        let new_prefix = prefix <> "[" <> int.to_string(index) <> "]"
        let props = parse(item, new_prefix)
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

pub fn get_string(ctx: YodelContext, key: String) -> Result(String, Nil) {
  dict.get(ctx.props, key)
}

pub fn get_string_or(ctx: YodelContext, key: String, default: String) -> String {
  case get_string(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_int(ctx: YodelContext, key: String) -> Result(Int, Nil) {
  case get_string(ctx, key) {
    Ok(value) -> {
      case int.parse(value) {
        Ok(int) -> Ok(int)
        Error(_) -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

pub fn get_int_or(ctx: YodelContext, key: String, default: Int) -> Int {
  case get_int(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_float(ctx: YodelContext, key: String) -> Result(Float, Nil) {
  case get_string(ctx, key) {
    Ok(value) -> {
      case float.parse(value) {
        Ok(float) -> Ok(float)
        Error(_) -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

pub fn get_float_or(ctx: YodelContext, key: String, default: Float) -> Float {
  case get_float(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

fn doc_error_to_string(error: DocError) -> String {
  let DocError(msg, loc) = error
  let #(line, col) = loc
  "Error at line "
  <> int.to_string(line)
  <> ","
  <> int.to_string(col)
  <> ": "
  <> msg
}

fn file_error_to_string(error: FileError) -> String {
  simplifile.describe_error(error)
}
