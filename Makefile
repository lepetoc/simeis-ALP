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

debian:
	cd ./target/release; \
	mkdir -p ./simeis-server_V0/usr/bin; \
	cp simeis-server ./simeis-server_V0/usr/bin; \
	mkdir -p simeis-server_V0/DEBIAN; \
	cp control simeis-server_V0/DEBIAN; \
	dpkg-deb --build simeis-server_V0; \
