FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile kernel bin/server.dart -o bin/server.dill

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /usr/lib/dart/bin/dart /usr/bin/
COPY --from=build /app/bin/server.dill /app/bin/
COPY --from=build /app/assets /app/assets

# Start server.
EXPOSE 8080
CMD ["dart", "bin/server.dill"]
