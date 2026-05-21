# Template Engine Behavior

## Time Reference Transformation

When a template step contains time-related phrases, the template engine may transform them:

| Original | Becomes |
|----------|---------|
| "1 week since last touch" | "5 minutes since last touch" |
| "2 weeks since last touch" | "10 minutes since last touch" |
| "3 weeks since last touch" | "15 minutes since last touch" |
| "4+ weeks since last touch" | "17 minutes since last touch" |

### Workaround

1. Avoid time-based phrases in step names
2. Check created funnel steps immediately after creation
3. Manually edit steps via API PATCH if needed
