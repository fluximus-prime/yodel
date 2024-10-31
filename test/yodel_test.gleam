import envoy
import startest.{describe, it}
import startest/expect
import yodel

pub fn main() {
  startest.run(startest.default_config())
}

pub fn yodel_tests() {
  describe("yodel", [
    describe("yaml tests", [
      it("should load basic yaml value", fn() {
        let assert Ok(config) = yodel.load("foo.bar: fooey\n")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load full yaml value", fn() {
        let assert Ok(config) =
          yodel.load(
            "foo:
              bar: fooey",
          )
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load basic yaml file", fn() {
        let assert Ok(config) = yodel.load("./test/fixtures/short.yaml")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should not load basic yaml file", fn() {
        yodel.load("fake.yaml")
        |> expect.to_be_error
        Nil
      }),
      it("should resolve mustache template placeholder", fn() {
        envoy.set("example", "foo")
        let assert Ok(config) = yodel.load("foo.bar: {{example}}-bar")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("foo-bar")
      }),
    ]),
    describe("json tests", [
      it("should load basic json value", fn() {
        let assert Ok(config) = yodel.load("\"foo.bar\": \"fooey\"\n")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load full json value", fn() {
        let assert Ok(config) =
          yodel.load(
            "{
              \"foo\": {
                \"bar\": \"fooey\"
              }
            }",
          )
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load basic json file", fn() {
        let assert Ok(config) = yodel.load("./test/fixtures/short.json")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should not load basic json file", fn() {
        yodel.load("fake.json")
        |> expect.to_be_error
        Nil
      }),
    ]),
  ])
}
