import gleam/dict
import gleam/option.{Some}
import startest.{describe, it}
import startest/expect
import test_helpers.{with_env}
import yodel
import yodel/resolver
import yodel/types.{ResolverError, UnresolvedPlaceholder}

pub fn resolver_tests() {
  describe("resolver", [
    describe("basic resolution", [
      it("resolves simple placeholder default", fn() {
        dict.from_list([#("foo", "${BAR:fooey}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      }),
      it("resolves simple placeholder", fn() {
        let env = dict.from_list([#("BAR", Some("fooey"))])
        use <- with_env(env)
        dict.from_list([#("foo", "${BAR}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      }),
      it("ignores default value when placeholder resolves", fn() {
        let env = dict.from_list([#("BAR", Some("fooey"))])
        use <- with_env(env)
        dict.from_list([#("foo", "${BAR:fooed}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      }),
    ]),
    describe("nested placeholders", [
      it("resolves nested placeholders", fn() {
        let env = dict.from_list([#("BAZ", Some("fooey"))])
        use <- with_env(env)
        dict.from_list([#("foo", "${BAR:${BAZ}}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      }),
      it("resolves nested placeholder defaults", fn() {
        dict.from_list([#("foo", "${BAR:${BAZ:fooey}}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      }),
    ]),
    describe("multiple placeholders", [
      it("resolves multiple placeholders", fn() {
        let env =
          dict.from_list([#("BAR", Some("fooey")), #("BAZ", Some("dooey"))])
        use <- with_env(env)
        dict.from_list([#("foo", "${BAR}-${BAZ}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey-dooey")
      }),
      it("resolved multiple placeholder defaults", fn() {
        dict.from_list([#("foo", "${BAR:fooey}-${BAZ:dooey}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey-dooey")
      }),
    ]),
    describe("resolution mode", [
      it("fails in strict mode with missing env var", fn() {
        let options =
          yodel.default_options() |> yodel.with_resolve_mode(yodel.strict)
        dict.from_list([#("foo", "${MISSING}")])
        |> resolver.resolve_properties(options)
        |> expect.to_be_error
        |> expect.to_equal(
          ResolverError(UnresolvedPlaceholder("MISSING", "${MISSING}")),
        )
      }),
      it("preserves placeholder in lenient mode", fn() {
        let options =
          yodel.default_options() |> yodel.with_resolve_mode(yodel.lenient)
        dict.from_list([#("foo", "${MISSING}")])
        |> resolver.resolve_properties(options)
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("${MISSING}")
      }),
    ]),
  ])
}
