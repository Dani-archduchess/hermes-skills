---
name: ghl-integration
description: "Call the GoHighLevel (LeadConnector) v2 API. Use for: contacts CRUD, opportunities, pipelines, calendars, users, and any GHL operation Hermes needs to perform directly."
version: 1.0.0
tags: [ghl, gohighlevel, leadconnector, crm, api]
---

# GHL Integration

## Setup

Set your credentials:

```bash
export GHL_API_KEY=your_ghl_api_key      # Starts with "pit-"
export GHL_LOCATION_ID=your_location_id  # From GHL → Settings → API Keys
```

## Connection Details

| Field | Value |
|-------|-------|
| API Base | `https://services.leadconnectorhq.com` |
| Auth | `Bearer $GHL_API_KEY` |
| Required Headers | `Version: 2021-07-28`, `Content-Type: application/json` |
| Location ID | `$GHL_LOCATION_ID` — append as `?locationId=` query param |

## Auth Header Shorthand

```bash
AUTH_HEADERS='-H "Authorization: Bearer $GHL_API_KEY" -H "Version: 2021-07-28" -H "Content-Type: application/json"'
LOCATION="?locationId=$GHL_LOCATION_ID"
```

## Endpoint Reference

### Contacts

```bash
# List contacts
curl -s "https://services.leadconnectorhq.com/contacts/$LOCATION&limit=10" $AUTH_HEADERS

# Search contacts
curl -s -X POST "https://services.leadconnectorhq.com/contacts/search" $AUTH_HEADERS   -d "{\"locationId\":\"$GHL_LOCATION_ID\",\"query\":\"search term\",\"limit\":10}"

# Get single contact
curl -s "https://services.leadconnectorhq.com/contacts/{contactId}" $AUTH_HEADERS

# Create contact (locationId in body)
curl -s -X POST "https://services.leadconnectorhq.com/contacts/" $AUTH_HEADERS   -d "{\"locationId\":\"$GHL_LOCATION_ID\",\"firstName\":\"Name\",\"lastName\":\"Surname\",\"email\":\"email@example.com\"}"

# Update contact
curl -s -X PUT "https://services.leadconnectorhq.com/contacts/{contactId}" $AUTH_HEADERS   -d "{\"locationId\":\"$GHL_LOCATION_ID\",\"firstName\":\"Updated\"}"

# Delete contact
curl -s -X DELETE "https://services.leadconnectorhq.com/contacts/{contactId}" $AUTH_HEADERS
```

### Opportunities

```bash
# Search opportunities (locationId in BODY — NOT query param!)
curl -s -X POST "https://services.leadconnectorhq.com/opportunities/search" $AUTH_HEADERS   -d "{\"locationId\":\"$GHL_LOCATION_ID\",\"limit\":10,\"status\":\"open\"}"

# List pipelines
curl -s "https://services.leadconnectorhq.com/opportunities/pipelines$LOCATION" $AUTH_HEADERS
```

### Calendars

```bash
curl -s "https://services.leadconnectorhq.com/calendars/$LOCATION" $AUTH_HEADERS
```

### Users

```bash
curl -s "https://services.leadconnectorhq.com/users/$LOCATION" $AUTH_HEADERS
```

### Location Info

```bash
curl -s "https://services.leadconnectorhq.com/locations/$GHL_LOCATION_ID" $AUTH_HEADERS
```

## Pitfalls

1. **Opportunities needs locationId in BODY.** `POST /opportunities/search` — locationId goes in the JSON body, NOT as a query param. Using `?locationId=` returns 404.
2. **Contacts locationId is a query param.** `GET /contacts/?locationId=` — do NOT put it in the body for GET requests.
3. **Create contact requires locationId in body.** `POST /contacts/` with `{"locationId": "...", ...}`.
4. **API key is location-scoped.** Each pit- key only works for one location. Use the right key for each location.
5. **Never hardcode contact/opportunity IDs.** Always fetch fresh lists — IDs change.
