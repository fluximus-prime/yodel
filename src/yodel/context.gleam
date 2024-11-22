import gleam/dict
import gleam/float
import gleam/int
import gleam/string
import yodel/types.{
  type GetError, type Properties, type YodelContext, BoolValue, FloatValue,
  IntValue, PathNotFound, TypeError, YodelContext,
}

pub fn new(from props: Properties) -> YodelContext {
  YodelContext(props:)
}

pub fn get_string(ctx: YodelContext, path: String) -> Result(String, GetError) {
  case dict.get(ctx.props, path) {
    Ok(value) -> Ok(value)
    Error(_) -> Error(PathNotFound(path: path))
  }
}

pub fn get_string_or(ctx: YodelContext, path: String, default: String) -> String {
  case get_string(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_int(ctx: YodelContext, path: String) -> Result(Int, GetError) {
  case get_string(ctx, path) {
    Ok(value) -> {
      case int.parse(value) {
        Ok(int) -> Ok(int)
        Error(_) ->
          Error(TypeError(path:, expected: IntValue, got: string.inspect(value)))
      }
    }
    Error(e) -> Error(e)
  }
}

pub fn get_int_or(ctx: YodelContext, path: String, default: Int) -> Int {
  case get_int(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_float(ctx: YodelContext, path: String) -> Result(Float, GetError) {
  case get_string(ctx, path) {
    Ok(value) -> {
      case float.parse(value) {
        Ok(float) -> Ok(float)
        Error(_) ->
          Error(TypeError(
            path:,
            expected: FloatValue,
            got: string.inspect(value),
          ))
      }
    }
    Error(e) -> Error(e)
  }
}

pub fn get_float_or(ctx: YodelContext, path: String, default: Float) -> Float {
  case get_float(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_bool(ctx: YodelContext, path: String) -> Result(Bool, GetError) {
  case get_string(ctx, path) {
    Ok("True") -> Ok(True)
    Ok("False") -> Ok(False)
    Ok(value) ->
      Error(TypeError(path:, expected: BoolValue, got: string.inspect(value)))
    Error(e) -> Error(e)
  }
}

pub fn get_bool_or(ctx: YodelContext, path: String, default: Bool) -> Bool {
  case get_bool(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}
