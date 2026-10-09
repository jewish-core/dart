# Contributing

Thanks for helping. Bug reports with a date, a city, the result you got and the result you expected (with
its source: a luach, a rabbi, another library) are the most useful thing you can send.

## Setup

Dart 3.9 or later. From the repository root:

```sh
dart pub get
for p in jewish_date jewish_holidays jewish_zmanim; do (cd "$p" && dart test); done
```

Run the tests from inside each package, as the loop does, because the tests load their fixtures from
`test/fixtures/`.

## Pull requests

- One topic per pull request. CI runs format, analyze, tests and a publish dry run on every package.
- A change under `lib/` comes with a line in that package's `CHANGELOG.md`, under a `## Unreleased` heading.
- A change in behavior that npm does not share is a deliberate difference: add it to the package README.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org), with the package as
  the scope: `fix(jewish_zmanim): read the offset at local noon`.

## Parity fixtures

`test/fixtures/*.json` are generated from the npm packages and are not edited by hand. When a new npm version
is released, regenerate them, run the tests, and note the new version in the CHANGELOG.

## Releasing (maintainers)

Packages are published only by CI, through pub.dev automated publishing.

1. In the package's `pubspec.yaml`, raise `version` (Semantic Versioning).
2. In its `CHANGELOG.md`, rename `## Unreleased` to the version and add the `Parity:` line.
3. Merge to `main`, then push a tag named `<package>-v<version>`:

   ```sh
   git tag jewish_date-v1.0.1
   git push origin jewish_date-v1.0.1
   ```

Release in dependency order when several packages change: `jewish_date`, then `jewish_holidays`, then
`jewish_zmanim`.
