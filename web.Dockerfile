# ================================
# Build image
# ================================
FROM vapor/swift:5.2 as build
WORKDIR /build

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build \
	--enable-test-discovery \
	-c release \
	-Xswiftc -g

# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /run

# Copy build artifacts
COPY --from=build /build/.build/release /run
# Copy Swift runtime libraries
COPY --from=build /usr/lib/swift/ /usr/lib/swift/

ENTRYPOINT ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0"]
