import gleam/float
import gleam/int
import gleam/string
import yodel/errors.{
  type GetError, BoolValue, FloatValue, IntValue, PathNotFound, TypeError,
}
import yodel/properties.{type Properties}

pub opaque type Context {
  Context(properties: Properties)
}

pub fn new(from properties: Properties) -> Context {
  Context(properties:)
}

pub fn get_string(ctx: Context, path: String) -> Result(String, GetError) {
  case properties.get(ctx.properties, path) {
    Ok(value) -> Ok(value)
    Error(_) -> Error(PathNotFound(path: path))
  }
}

pub fn get_string_or(ctx: Context, path: String, default: String) -> String {
  case get_string(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_int(ctx: Context, path: String) -> Result(Int, GetError) {
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

pub fn get_int_or(ctx: Context, path: String, default: Int) -> Int {
  case get_int(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_float(ctx: Context, path: String) -> Result(Float, GetError) {
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

pub fn get_float_or(ctx: Context, path: String, default: Float) -> Float {
  case get_float(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn get_bool(ctx: Context, path: String) -> Result(Bool, GetError) {
  case get_string(ctx, path) {
    Ok("True") -> Ok(True)
    Ok("False") -> Ok(False)
    Ok(value) ->
      Error(TypeError(path:, expected: BoolValue, got: string.inspect(value)))
    Error(e) -> Error(e)
  }
}

pub fn get_bool_or(ctx: Context, path: String, default: Bool) -> Bool {
  case get_bool(ctx, path) {
    Ok(value) -> value
    Error(_) -> default
  }
}
