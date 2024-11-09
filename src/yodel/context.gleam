import gleam/dict
import gleam/float
import gleam/int
import gleam/string
import yodel/types.{
  type GetError, type Properties, type YodelContext, BoolValue, FloatValue,
  IntValue, KeyNotFound, TypeError, YodelContext,
}

pub fn new(from props: Properties) -> YodelContext {
  YodelContext(props:)
}

pub fn get_string(ctx: YodelContext, key: String) -> Result(String, GetError) {
  case dict.get(ctx.props, key) {
    Ok(value) -> Ok(value)
    Error(_) -> Error(KeyNotFound(key: key))
  }
}

pub fn get_string_or(ctx: YodelContext, key: String, default: String) -> String {
  case get_string(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_int(ctx: YodelContext, key: String) -> Result(Int, GetError) {
  case get_string(ctx, key) {
    Ok(value) -> {
      case int.parse(value) {
        Ok(int) -> Ok(int)
        Error(_) ->
          Error(TypeError(key:, expected: IntValue, got: string.inspect(value)))
      }
    }
    Error(e) -> Error(e)
  }
}

pub fn get_int_or(ctx: YodelContext, key: String, default: Int) -> Int {
  case get_int(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_float(ctx: YodelContext, key: String) -> Result(Float, GetError) {
  case get_string(ctx, key) {
    Ok(value) -> {
      case float.parse(value) {
        Ok(float) -> Ok(float)
        Error(_) ->
          Error(TypeError(
            key:,
            expected: FloatValue,
            got: string.inspect(value),
          ))
      }
    }
    Error(e) -> Error(e)
  }
}

pub fn get_float_or(ctx: YodelContext, key: String, default: Float) -> Float {
  case get_float(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_bool(ctx: YodelContext, key: String) -> Result(Bool, GetError) {
  case get_string(ctx, key) {
    Ok("True") -> Ok(True)
    Ok("False") -> Ok(False)
    Ok(value) ->
      Error(TypeError(key:, expected: BoolValue, got: string.inspect(value)))
    Error(e) -> Error(e)
  }
}

pub fn get_bool_or(ctx: YodelContext, key: String, default: Bool) -> Bool {
  case get_bool(ctx, key) {
    Ok(value) -> value
    Error(_) -> default
  }
}
