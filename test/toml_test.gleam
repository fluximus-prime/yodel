///////////////////////////////////////

import startest.{describe, it}
import test_helpers
import yodel

pub fn toml_tests() {
  describe("parser", [
    describe("toml", [
      it("loads simple file", fn() {
        test_helpers.assert_loads_simple_file(
          format: yodel.toml,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("loads complex file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.toml,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("does not load fake file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.toml,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("loads file with no extension", fn() {
        test_helpers.assert_loads_file_with_no_extension(
          format: yodel.toml,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("loads simple string", fn() {
        test_helpers.assert_loads_simple_string(
          format: yodel.toml,
          content: "foo.bar = \"fooey\"",
        )
      }),
      it("parses basic value", fn() {
        let content =
          "
        [foo]
        bar = \"fooey\"
        "
        test_helpers.assert_parses_basic_value(
          format: yodel.toml,
          content:,
          path: "foo.bar",
          value: "fooey",
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
          format: yodel.toml,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
    ]),
  ])
}
