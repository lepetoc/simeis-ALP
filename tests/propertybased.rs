#[test]
fn test_addition() {
    create_property_based_test(&[
    ], |rng| {
        let x = rng.random_range(0..10000);
        let y = rng.random_range(0..10000);
        assert!(x + y > x);
        assert!(x + y > y);
    })
}
