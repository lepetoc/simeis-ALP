use rand::{rngs::SmallRng, Rng, SeedableRng};

const NB_ITER : usize = 100000;

fn create_property_based_test<T: Fn(&mut SmallRng)>(reg: &[u64], f: T) {
    let mut seed_rng = rand::rng();
    for i in 0..NB_ITER {
        let seed = if let Some(seed) = reg.get(i) {
            *seed
        } else {
            seed_rng.random()
        };

        let mut rng = SmallRng::seed_from_u64(seed);
        println!("{i}/{NB_ITER}, seed {seed}");
        f(&mut rng);
    }
}

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
