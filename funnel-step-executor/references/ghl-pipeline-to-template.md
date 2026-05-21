# GHL Pipeline → Dashboard Template Conversion

## 1. Fetch GHL pipeline stages

```bash
curl -s "https://services.leadconnectorhq.com/opportunities/pipelines?locationId=$GHL_LOCATION_ID" \
  -H "Authorization: Bearer $GHL_API_KEY" \
  -H "Version: 2021-07-28"
```

## 2. Map stages to template steps

| Step field | Source |
|-----------|--------|
| `name` | GHL stage name |
| `order` | Position (1-indexed) |
| `description` | What this stage represents |
| `agent_instructions` | Actionable steps for the marketer agent |

## 3. Create template

```bash
curl -s -X POST http://localhost:3001/api/templates \
  -H "Authorization: Bearer $DASHBOARD_API_KEY" \
  -H "Content-Type: application/json" \
  -d @/tmp/ghl_template.json
```

## 4. Categories

- Lead nurturing → `lead_gen`
- Booking → `booking`
- E-commerce → `ecom`
- Product launch → `product_launch`
- Custom → `custom`
