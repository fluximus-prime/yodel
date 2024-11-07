import envoy
import gleam/bbmustache.{string}
import gleam/dict
import gleam/io
import yodel/types.{type Properties}

pub fn resolve_properties(on props: Properties) -> Properties {
  dict.fold(props, dict.new(), fn(acc, key, value) {
    let resolved = resolve_property(#(key, value))
    dict.merge(acc, resolved)
  })
}

pub fn resolve_property(on property: #(String, String)) -> Properties {
  let #(key, value) = property
  let rendered = case bbmustache.compile(value) {
    Ok(template) ->
      bbmustache.render(template, [
        #(
          key,
          string(case envoy.get(key) {
            Ok(value) -> value
            Error(_) -> value
          }),
        ),
      ])
    Error(_) -> value
  }
  io.debug(key <> " -> " <> rendered)
  dict.from_list([#(key, rendered)])
}
