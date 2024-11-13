import startest.{describe, it}
import test_helpers
import yodel

pub fn yaml_tests() {
  describe("yaml", [
    it("loads simple file", fn() {
      test_helpers.assert_loads_simple_file(
        yodel.yaml,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("loads complex file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.yaml,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("does not load fake file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.yaml,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("loads simple string", fn() {
      let content = "foo.bar: fooey"
      test_helpers.assert_loads_simple_string(yodel.yaml, content)
    }),
    it("parses basic value", fn() {
      let content =
        "
        foo:
          bar: fooey
        "
      test_helpers.assert_parses_basic_value(
        yodel.yaml,
        content,
        "foo.bar",
        "fooey",
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
        yodel.yaml,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
  ])
}
