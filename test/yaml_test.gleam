import startest.{describe, it}
import test_helpers
import yodel

pub fn yaml_tests() {
  describe("parser", [
    describe("yaml", [
      it("loads simple file", fn() {
        test_helpers.assert_loads_simple_file(
          format: yodel.yaml,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("loads complex file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.yaml,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("does not load fake file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.yaml,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("loads file with no extension", fn() {
        test_helpers.assert_loads_file_with_no_extension(
          format: yodel.yaml,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("loads simple string", fn() {
        test_helpers.assert_loads_simple_string(
          format: yodel.yaml,
          content: "foo.bar: fooey",
        )
      }),
      it("parses basic value", fn() {
        let content =
          "
        foo:
          bar: fooey
        "
        test_helpers.assert_parses_basic_value(
          format: yodel.yaml,
          content:,
          path: "foo.bar",
          value: "fooey",
        )
      }),
      it("parses array", fn() {
        let content =
          "
        foo:
          - bar: fooey
          - baz: fooed
        "
        test_helpers.assert_parses_array(
          format: yodel.yaml,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
    ]),
  ])
}
