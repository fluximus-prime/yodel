import envoy
import gleam/dict
import gleam/regex.{type Regex}
import gleam/string
import yodel/types.{type Properties}

pub fn resolve_properties(on props: Properties) -> Properties {
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
