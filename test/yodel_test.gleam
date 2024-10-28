import startest.{describe, it}
import startest/expect
import yodel

pub fn main() {
  startest.run(startest.default_config())
}
// pub fn yodel() {
//   describe("yodel tests", [
//     it(
//       "should return defaults.version = 1.0",
//       yodel.get("PATH")
//       |>
//     ),
//   ])
// }
