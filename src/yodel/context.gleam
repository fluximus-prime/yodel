import gleam/dict
import gleam/float
import gleam/int
import yodel/types.{type Properties, type YodelContext, YodelContext}

pub fn new(from props: Properties) -> YodelContext {
  YodelContext(props:)
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

pub fn get_bool(ctx: YodelContext, key: String) -> Bool {
  case get_string(ctx, key) {
    Ok("true") -> True
    Ok("false") -> False
    _ -> False
  }
}

pub fn get_bool_or(ctx: YodelContext, key: String, default: Bool) -> Bool {
  case get_bool(ctx, key) {
    True -> True
    False -> default
  }
}
