import envoy
import gleam/bbmustache.{string}
import gleam/dict
import yodel/types.{type ConfigError, type Properties}

pub fn properties(on props: Properties) -> Result(Properties, ConfigError) {
  dict.fold(props, dict.new(), fn(acc, key, value) {
    let resolved = property(#(key, value))
    dict.merge(acc, resolved)
  })
  |> Ok
}

pub fn property(on property: #(String, String)) -> Properties {
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
  dict.from_list([#(key, rendered)])
}
