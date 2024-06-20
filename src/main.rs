fn main() {
    println!("Hello, finch!");
}

fn adder(a: i32, b: i32) -> i32 {
    a + b
}

#[test]
fn simple_test() {
    assert_eq!(adder(2, 2), 4);
}
