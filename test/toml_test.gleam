import startest.{describe, it}
import test_helpers
import yodel

pub fn toml_tests() {
  describe("toml", [
    it("loads simple file", fn() {
      test_helpers.assert_loads_simple_file(
        yodel.toml,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("loads complex file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.toml,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("does not load fake file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.toml,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("loads simple string", fn() {
      let content = "foo.bar = \"fooey\""
      test_helpers.assert_loads_simple_string(yodel.toml, content)
    }),
    it("parses basic value", fn() {
      let content =
        "
          [foo]
          bar = \"fooey\"
        "
      test_helpers.assert_parses_basic_value(
        yodel.toml,
        content,
        "foo.bar",
        "fooey",
      )
    }),
    it("parses array", fn() {
      let content =
        "
          [[foo]]
          bar = \"fooey\"

          [[foo]]
          baz = \"fooed\"
        "
      test_helpers.assert_parses_array(
        yodel.toml,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
  ])
}
