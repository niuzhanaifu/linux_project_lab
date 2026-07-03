# Repository Guidelines

## Project Structure & Module Organization
This repository currently contains lightweight learning and planning materials:

- `plan.md`: planning or notes entry point.
- root screenshot PNG: reference asset kept beside the planning note.

Keep repository-wide documentation in the root. If more media files are added, group them under `assets/` with descriptive names. If executable examples are introduced, place source code in `src/`, helper scripts in `scripts/`, and tests in `tests/` so the project remains easy to scan.

## Build, Test, and Development Commands
No project-specific build or test system is defined yet. Useful local inspection commands are:

- `rg --files`: list repository files quickly.
- `Get-ChildItem -Force`: inspect root contents, including hidden files.
- `Get-Content .\plan.md`: review the current planning document.

When adding a language runtime or toolchain, document the exact install, run, build, format, and test commands here.

## Coding Style & Naming Conventions
For Markdown, use `#`-style headings, short sections, and concise instructional prose. Prefer UTF-8 text and keep filenames descriptive. Use lowercase kebab-case for new documentation files, for example `linux-notes.md`; keep screenshots named by subject and context.

For future code, follow the formatter and naming conventions of the chosen language. Add the formatter command to this guide when tooling is introduced.

## Testing Guidelines
There are no automated tests at this time. For documentation changes, manually verify that links, headings, and image references render correctly. When adding code, include tests with the change and place them under `tests/` or the standard location for the selected framework. Use clear test names that describe behavior, such as `test_parse_command_options`.

## Commit & Pull Request Guidelines
No Git history is available in this working directory, so no existing commit convention can be inferred. Use short, imperative commit messages with a scoped prefix when helpful, for example `docs: add shell notes` or `fix: correct command example`.

Pull requests should include a concise summary, changed files or areas, verification performed, and screenshots when visual assets or rendered documentation change. Link related issues or task notes when available.

## Security & Configuration Tips
Do not commit secrets, access tokens, private hostnames, or machine-specific absolute paths. Keep generated files out of the repository unless they are intentional learning artifacts or documented reference assets.
