import yodel/context
import yodel/options.{type YodelOptions} as cfg
import yodel/parser
import yodel/types.{type ConfigError, type GetError, type YodelContext}

pub type Format =
  cfg.Format

pub const auto_detect = cfg.Auto

pub const json = cfg.Json

pub const toml = cfg.Toml

pub const yaml = cfg.Yaml

pub fn load(from input: String) -> Result(YodelContext, ConfigError) {
  load_with_options(default_options(), input)
}

pub fn load_with_options(
  with options: YodelOptions,
  from input: String,
) -> Result(YodelContext, ConfigError) {
  parser.parse(input, options)
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

pub fn options(format: Format, resolve: Bool, validate: Bool) -> YodelOptions {
  cfg.new(format:, resolve:, validate:)
}

pub fn default_options() -> YodelOptions {
  cfg.default()
}

pub fn with_format(
  options options: YodelOptions,
  format format: Format,
) -> YodelOptions {
  cfg.with_format(options:, format:)
}

pub fn with_resolve(
  options options: YodelOptions,
  resolve resolve: Bool,
) -> YodelOptions {
  cfg.with_resolve(options:, resolve:)
}

pub fn with_validate(
  options options: YodelOptions,
  validate validate: Bool,
) -> YodelOptions {
  cfg.with_validate(options:, validate:)
}

pub fn format(options options: YodelOptions) -> Format {
  cfg.format(options)
}

pub fn resolve(options options: YodelOptions) -> Bool {
  cfg.resolve(options)
}

pub fn validate(options options: YodelOptions) -> Bool {
  cfg.validate(options)
}
