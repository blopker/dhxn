# Use latest stable channel SDK.
FROM dart:2.19 AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile jit-snapshot bin/server.dart

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server.jit app/bin/
COPY --from=build /usr/lib/dart/bin/dart /usr/bin/
EXPOSE 8080
ENTRYPOINT ["dart", "/app/bin/server.jit"]
