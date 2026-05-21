---
name: ghl-integration
description: "Call the GoHighLevel (LeadConnector) v2 API for The Relax Estate. Use for: contacts CRUD, opportunities, pipelines, calendars, users, forms, submissions, and any GHL operation Hermes needs to perform directly."
version: 1.1.0
tags: [ghl, gohighlevel, leadconnector, crm, api]
---

# GHL Integration — The Relax Estate

## Connection Details

| Field | Value |
|-------|-------|
| Location | The Relax Estate |
| Location ID | `ttFcthXlmNejS8lHdriw` |
| Company ID | `WQ6uo86Lh0jHv1zEvayq` |
| API Base | `https://services.leadconnectorhq.com` |
| Auth | `Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363` |
| Required Headers | `Version: 2021-07-28`, `Content-Type: application/json` |

## Auth Header Shorthand

Use this in all curl commands:

```bash
-H "Authorization: Bearer pit-eff1a3a2-ca83-4c88-bc53-f32ee3750363" \
-H "Version: 2021-07-28" \
-H "Content-Type: application/json"
```

## Endpoint Reference

### Contacts

```bash
# List contacts (pagination: ?limit= & ?skip=)
curl -s "https://services.leadconnectorhq.com/contacts/?locationId=ttFcthXlmNejS8lHdriw&limit=10" \
  $AUTH_HEADERS

# Search contacts
curl -s -X POST "https://services.leadconnectorhq.com/contacts/search" \
  $AUTH_HEADERS \
  -d '{"locationId":"ttFcthXlmNejS8lHdriw","query":"search term","limit":10}'

# Get single contact
curl -s "https://services.leadconnectorhq.com/contacts/{contactId}" \
  $AUTH_HEADERS

# Create contact (locationId in body)
curl -s -X POST "https://services.leadconnectorhq.com/contacts/" \
  $AUTH_HEADERS \
  -d '{"locationId":"ttFcthXlmNejS8lHdriw","firstName":"Name","lastName":"Surname","email":"email@example.com","phone":"+15551234567"}'

# Update contact
curl -s -X PUT "https://services.leadconnectorhq.com/contacts/{contactId}" \
  $AUTH_HEADERS \
  -d '{"locationId":"ttFcthXlmNejS8lHdriw","firstName":"Updated"}'

# Delete contact
curl -s -X DELETE "https://services.leadconnectorhq.com/contacts/{contactId}" \
  $AUTH_HEADERS
```

### Opportunities

```bash
# Search opportunities (locationId in BODY — NOT query param!)
curl -s -X POST "https://services.leadconnectorhq.com/opportunities/search" \
  $AUTH_HEADERS \
  -d '{"locationId":"ttFcthXlmNejS8lHdriw","limit":10,"status":"open"}'

# List pipelines
curl -s "https://services.leadconnectorhq.com/opportunities/pipelines?locationId=ttFcthXlmNejS8lHdriw" \
  $AUTH_HEADERS
```

### Calendars

```bash
curl -s "https://services.leadconnectorhq.com/calendars/?locationId=ttFcthXlmNejS8lHdriw" \
  $AUTH_HEADERS
```

### Users

```bash
curl -s "https://services.leadconnectorhq.com/users/?locationId=ttFcthXlmNejS8lHdriw" \
  $AUTH_HEADERS
```

### Location Info

```bash
curl -s "https://services.leadconnectorhq.com/locations/ttFcthXlmNejS8lHdriw" \
  $AUTH_HEADERS
```

### Forms

```bash
# List forms (pagination: ?limit= & ?skip=)
curl -s "https://services.leadconnectorhq.com/forms/?locationId=ttFcthXlmNejS8lHdriw&limit=50" \
  $AUTH_HEADERS

# Get form submissions (pagination: ?limit= & ?skip=)
curl -s "https://services.leadconnectorhq.com/forms/submissions?locationId=ttFcthXlmNejS8lHdriw&formId={formId}&limit=20" \
  $AUTH_HEADERS
```

**Response shape for forms:**
```json
{
  "forms": [
    {
      "id": "eW94IwtuwLDBo1ijaVpz",
      "locationId": "ttFcthXlmNejS8lHdriw",
      "name": "Form name"
    }
  ],
  "total": 421
}
```

**Response shape for submissions:**
```json
{
  "submissions": [
    {
      "id": "6a0dba...",
      "contactId": "HCibys...",
      "formId": "eW94IwtuwLDBo1ijaVpz",
      "name": "Full Name",
      "email": "email@example.com",
      "others": {
        "first_name": "...",
        "last_name": "...",
        "phone": "+1xxx...",
        "date_of_birth": "1977-05-06",
        "address": "123 Main St",
        "city": "City",
        "state": "ST",
        "postal_code": "12345",
        "...custom fields...": "..."
      },
      "createdAt": "2026-05-20T13:42:38.999Z",
      "external": false
    }
  ],
  "meta": {
    "total": 25,
    "currentPage": 1,
    "nextPage": 2,
    "prevPage": null
  }
}
```

**Key form IDs (The Relax Estate):**

- Form ID | Name
- `eW94IwtuwLDBo1ijaVpz` | Onboarding Form Pro Subscription @97 - Updated for Automation
- `3II98q4ez1sNn1DJpLWu` | Onboarding Form Starter Subscription @47 - Updated for Automation
- `9GbqYqfvsjlQ5JUEM2JD` | Relax Estate Onboarding Sign In Sheet
- `OD5ZDdaSCsSavE1LeKzL` | Relax Estate Webinar In Sheet

## Existing Pipelines

| Pipeline | ID | Stages |
|----------|------|--------|
| 'Touch Base' Pipeline | I5f2peiNcq7WkEeefxzT | 6 |
| Financial Advisor Leads | Q7FeQT6kdShQUnhpXWYv | 7 |
| Leads | HrBYzEECDXJgPtKGr9aA | 10 |

## Existing Contacts (sample)

| Name | Email | ID |
|------|-------|-----|
| Dawn Bross | dawnbross@gmail.com | bKEaIbtxkMDTaIjY19vf |
| Devin Ruiz | devinm.ruiz@yahoo.com | V4pijGn36AsfnDV2KTQD |

## Users

| Name | Email | Role |
|------|-------|------|
| Abena Oduro Osae | abena@toamsfinancial.com | Admin |
| Mario Payne | support@mp.therelaxestate.com | Owner |

## Related Skills

- **`funnel-step-executor`** — The marketer cron watchdog that processes dashboard funnel steps using AgentMail and GHL. See its `references/ghl-pipeline-to-template.md` for converting GHL pipelines into dashboard templates.

1. **Opportunities needs locationId in BODY.** `POST /opportunities/search` — locationId goes in the JSON body, NOT as a query param. Using `?locationId=` returns 404.
2. **Contacts locationId is a query param.** `GET /contacts/?locationId=` — do NOT put it in the body for GET requests.
3. **Create contact requires locationId in body.** `POST /contacts/` with `{"locationId": "ttFcthXlmNejS8lHdriw", ...}`.
4. **API key is location-scoped.** This pit- key only works for location `ttFcthXlmNejS8lHdriw`. For other locations, a different key is needed.
5. **Never hardcode contact/opportunity IDs.** Always fetch fresh lists — IDs may change or be deleted.
6. **Forms submissions paginate.** `GET /forms/submissions` returns 20 per page. Check `meta.nextPage` to know if there are more. Phone numbers are partially redacted (e.g., `+178****8200`).
7. **Form custom field IDs are opaque UUIDs.** Custom fields in the `others` object use UUID keys like `wSI3HshTZ2VmCmaWrKcE`. These map to specific form fields — the field label is not returned by the API, so you'll need to cross-reference with the form builder UI to map UUIDs to field names.
