# Use latest stable channel SDK.
FROM dart:2.18 AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/
ADD assets /app/assets

# Start server.
EXPOSE 8080
CMD ["./server"]
