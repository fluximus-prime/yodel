import gleam/dict
import yodel/types.{
  type ConfigError, type Properties, EmptyConfig, InvalidConfig, ValidationError,
}

pub fn validate_properties(props: Properties) -> Result(Properties, ConfigError) {
  case dict.size(props) {
    0 -> EmptyConfig |> ValidationError |> Error
    1 -> {
      case dict.get(props, "") {
        Ok(_) ->
          InvalidConfig("Invalid config: value without key")
          |> ValidationError
          |> Error
        Error(_) -> props |> Ok
      }
    }
    _ -> props |> Ok
  }
}
