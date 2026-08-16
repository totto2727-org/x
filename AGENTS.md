# x

## Repository structure

```text
.github/workflows/  Validation and Mooncakes publishing workflows
src/copy/            Independent logical-copy trait, tests, and package README
src/json/            JSON flattening, reconstruction, path formats, and package README
src/path/            Validated absolute and relative path values and package README
src/toml/            Owned TOML-to-JSON conversion wrapper and package README
src/yaml/            Owned YAML-to-JSON conversion wrapper and package README
flake.nix            Nix development shell for MoonBit
moon.mod             Module metadata and dependencies
README.mbt.md        Physical module overview and canonical MoonBit README
README.md            Relative symlink to README.mbt.md
```

## Development commands

### Execution rules

- Run commands from the repository root.
- Enter the environment with `nix develop` before running MoonBit commands.
- Keep the root link `README.md -> README.mbt.md`; the root README is a physical module overview.
- Keep detailed package documentation in each `src/<package>/README.mbt.md`; only the root README has a `README.md` link.
- Run the full check sequence after changing public declarations, serialization behavior, path parsing, or documentation examples.

### Standard tasks

- `nix develop` — Enter the Nix-provided MoonBit environment.
- `moon fmt` — Format MoonBit source and literate documentation.
- `moon fmt --check` — Verify formatting without writing changes.
- `moon check src/<package>/README.mbt.md` — Check one package-specific literate README.
- `moon test src/<package>/README.mbt.md` — Run one package-specific README example.
- `moon check --deny-warn` — Type-check every package and reject warnings.
- `moon build` — Build every package.
- `moon test` — Run the complete test suite.
- `moon package --list` — Inspect the files included in the Mooncakes package.
- `nix flake check --all-systems --no-build` — Evaluate the development shell for every supported system.

## Architecture

### Package boundaries

- `copy` is independent of the serialization and path packages and defines explicit logical-copy behavior.
- `path` wraps `moonbitlang/x/path.Path`, normalizes at construction, and preserves absolute or relative form through typed operations.
- `json` owns path parsing plus bounded flattening and reconstruction over core `Json` values.
- `yaml` and `toml` use owned wrapper types because MoonBit does not permit implementing a foreign trait for a foreign type.

### Error and conversion policy

- JSON path parsing and reconstruction expose `FlattenJsonError`; do not replace typed failures with unchecked aborts.
- YAML and TOML conversion reject or abort on non-finite values because JSON cannot represent them.
- TOML date-time values flatten to strings and intentionally do not regain date-time variants when decoded from JSON.

### Public API documentation

- Mooncakes is the canonical API reference for this published module.
- Keep every public declaration documented with caller-visible behavior, constraints, and failure semantics so registry documentation remains complete.
- Keep checked examples close to the declarations or in the literate README when they demonstrate cross-package usage.

## Development tools

- **MoonBit**: Builds, checks, tests, formats, and packages the module.
- **Mooncakes**: Publishes and renders the canonical API documentation from source comments.
- **Nix flakes**: Provide the development toolchain used locally and in CI.
- **GitHub Actions**: Run validation and publish main-branch state with the configured repository secret.

## Package-specific rules

- Preserve the `source = "./src"` package layout and import packages by their published subpaths.
- Keep flattening limits, path formats, empty-container behavior, and conflict detection aligned between implementation, tests, and public doc comments.
- Keep wrapper conversions explicit about lossy date-time handling, unsupported non-finite values, and JSON `null` behavior.
- Update `moon.mod` and the lock file together when dependencies or package metadata change.
- Run `moon fmt --check`, `moon check --deny-warn`, `moon build`, `moon test`, `moon package --list`, and the all-systems flake evaluation before handoff.

_This AGENTS.md was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [AGENTS template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/agents/template.md)._
