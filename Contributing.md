# Contributing to HarmonyOS Migration Rulesets

Thank you for your interest in contributing! Every rule you add, every example you share, and every bug you report makes HarmonyOS migration easier for thousands of developers.

## How to Contribute

### Reporting Issues

- **Incorrect rule:** A transformation produces wrong HarmonyOS code → [Open a bug report](.github/ISSUE_TEMPLATE/bug-report.md)
- **Missing mapping:** An Android/iOS API has no corresponding rule → [Request a rule](.github/ISSUE_TEMPLATE/rule-request.md)
- **New migration path:** You want Flutter → HMOS or another path → [Request a migration path](.github/ISSUE_TEMPLATE/migration-path-request.md)

### Contributing Rules

1. **Fork** this repository
2. **Choose** the migration path directory (e.g., `android-to-harmonyos/rules/`)
3. **Follow** the rule format specification in [docs/rule-format-spec.md](docs/rule-format-spec.md)
4. **Include** at minimum:
   - Source code example (original platform)
   - Target code example (HarmonyOS)
   - At least one anti-pattern
   - Verification checklist items
5. **Test** your rules by actually using them with an AI tool
6. **Submit** a pull request

### Contributing Examples

Example apps live in `{migration-path}/examples/`. Each example should include:

```
examples/your-example/
├── android/          # Original source code
├── harmonyos/        # Converted HarmonyOS code
└── README.md         # What this example demonstrates
```

### Contributing AI Tool Templates

If you use an AI tool not yet supported, add a template in `{migration-path}/templates/`:

1. Adapt the master ruleset to your tool's format
2. Include setup instructions as comments at the top
3. Test that the template works with the tool

## Rule Quality Standards

Every rule must:

- ✅ Include working source and target code examples
- ✅ Be verified against HarmonyOS 5.0+ APIs
- ✅ Follow the frontmatter schema in the format spec
- ✅ List edge cases and caveats in the Notes section
- ✅ Not duplicate existing rules (check before adding)

## Commit Convention

```
type(scope): description

feat(android-rules): add Room → RelationalStore migration rules
fix(ui-components): correct ArkUI List ForEach key generator syntax
docs(readme): add Windsurf setup instructions
example(todo-app): add complete before/after todo app migration
```

Types: `feat`, `fix`, `docs`, `example`, `template`, `chore`

## Code of Conduct

Be respectful, constructive, and inclusive. We're all here to make HarmonyOS migration better.

## Questions?

Open a discussion or reach out to the maintainers. No question is too basic — if you're confused, others probably are too.
