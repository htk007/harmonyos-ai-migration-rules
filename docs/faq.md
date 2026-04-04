# Frequently Asked Questions

## General

**Q: Do I need to know HarmonyOS to use these rule sets?**
A: Basic familiarity helps, but the rule sets are designed to guide AI assistants through the conversion. You should understand the app you're migrating and be able to verify the output.

**Q: Which AI tool works best with these rule sets?**
A: Any tool that supports custom instructions or system prompts. Tools with larger context windows (Claude, Cursor) can load more rules simultaneously, but all supported tools produce good results with the modular approach.

**Q: Can I use these rules with my company's internal LLM?**
A: Yes. The rules are plain Markdown. Use them as system prompts, include them in RAG pipelines, or fine-tune on them — whatever fits your infrastructure.

**Q: Are the rule sets complete? Will they handle my entire app?**
A: They cover the most common patterns and APIs. Complex or niche features may require manual work. If you find gaps, please open an issue or contribute a rule.

## Migration

**Q: Should I migrate my entire app at once?**
A: No. Migrate module by module, screen by screen. Start with simple components to validate your workflow.

**Q: My app uses third-party libraries. Are those covered?**
A: Currently, rules focus on platform APIs and frameworks. Third-party library equivalents (e.g., Glide → HarmonyOS image loading) will be added in future phases.

**Q: What about apps that use both Compose and XML layouts?**
A: The UI component rules cover both Jetpack Compose and XML layout conversion. Load the `ui-components.md` rule set which includes mappings for both approaches.

## Contributing

**Q: I found a rule that produces incorrect code. What should I do?**
A: Open a bug report with the source code, the generated output, and what the correct output should be. This helps us fix it quickly.

**Q: Can I add rules for a migration path not yet listed (e.g., Flutter → HMOS)?**
A: Absolutely. Open a migration path request issue first so we can coordinate, then follow the contributing guidelines.

**Q: Do I need to test my rules with every AI tool?**
A: Testing with at least one AI tool is required. Testing with multiple tools is appreciated but not mandatory.
