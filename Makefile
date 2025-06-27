build-simeis:
	RUSTFLAGS="-C code-model=kernel" \
	CARGO_PROFILE_RELEASE_CODEGEN_UNIT=1 \
	CARGO_PROFILE_RELEASE_STRIP=symbols \
	cargo build --release

generate-docs:
	typst compile ./doc/manual.typ

check:
	cargo check

test:
	cargo test

clean:
	cargo clean

format:
	cargo fmt --check

lint:
	cargo clippy -- -D warnings
