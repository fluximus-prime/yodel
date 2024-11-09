import yodel/context
import yodel/parser
import yodel/types.{
  type ConfigError, type GetError, type YodelContext, ParseOptions,
}

pub fn load(from string: String) -> Result(YodelContext, ConfigError) {
  parser.parse(string, ParseOptions(resolve: True))
}

pub fn get_string(ctx: YodelContext, key: String) -> Result(String, GetError) {
  context.get_string(ctx, key)
}

pub fn get_string_or(ctx: YodelContext, key: String, default: String) -> String {
  context.get_string_or(ctx, key, default)
}

pub fn get_int(ctx: YodelContext, key: String) -> Result(Int, GetError) {
  context.get_int(ctx, key)
}

pub fn get_int_or(ctx: YodelContext, key: String, default: Int) -> Int {
  context.get_int_or(ctx, key, default)
}

pub fn get_float(ctx: YodelContext, key: String) -> Result(Float, GetError) {
  context.get_float(ctx, key)
}

pub fn get_float_or(ctx: YodelContext, key: String, default: Float) -> Float {
  context.get_float_or(ctx, key, default)
}

pub fn get_bool(ctx: YodelContext, key: String) -> Result(Bool, GetError) {
  context.get_bool(ctx, key)
}

pub fn get_bool_or(ctx: YodelContext, key: String, default: Bool) -> Bool {
  context.get_bool_or(ctx, key, default)
}
