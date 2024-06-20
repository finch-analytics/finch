/// A simple adder function
///
/// # Examples
/// ```
/// use finch::adder;
///
/// let result = adder(5, 7);
/// assert_eq!(result, 12);
/// ```
pub fn adder(a: i32, b: i32) -> i32 {
    a + b
}

#[test]
fn simple_test() {
    assert_eq!(adder(2, 2), 4);
}
