import yodel/context
import yodel/loaders/common
import yodel/types.{type YodelContext, type YodelError}

pub fn load(from string: String) -> Result(YodelContext, YodelError) {
  common.load(string)
}

pub fn get_string(ctx: YodelContext, key: String) -> Result(String, Nil) {
  context.get_string(ctx, key)
}

pub fn get_string_or(ctx: YodelContext, key: String, default: String) -> String {
  context.get_string_or(ctx, key, default)
}

pub fn get_int(ctx: YodelContext, key: String) -> Result(Int, Nil) {
  context.get_int(ctx, key)
}

pub fn get_int_or(ctx: YodelContext, key: String, default: Int) -> Int {
  context.get_int_or(ctx, key, default)
}

pub fn get_float(ctx: YodelContext, key: String) -> Result(Float, Nil) {
  context.get_float(ctx, key)
}

pub fn get_float_or(ctx: YodelContext, key: String, default: Float) -> Float {
  context.get_float_or(ctx, key, default)
}
