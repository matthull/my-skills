# API Documentation Extraction (MANDATORY)

## CRITICAL: Extract BEFORE Implementation (ABSOLUTE)

**You MUST NEVER write API client code without doc extraction**

**RATIONALE:** Guessing API specs = broken integration.

## Mandatory Extraction Template

**You MUST complete this BEFORE writing any code:**

```markdown
## API SPECIFICATION EXTRACTION

**Doc URL**: [exact URL fetched]

**HTTP Method**: [QUOTE from docs]
**Endpoint Path**: [QUOTE from docs]
**Content-Type**: [QUOTE from docs]
**Request Format**: [QUOTE from docs]
**Required Headers**: [QUOTE from docs]
**File Upload Method**: [QUOTE: multipart vs JSON vs binary]
**Field Names**: [QUOTE exact field names]
**Response Format**: [QUOTE from docs]
**Error Codes**: [QUOTE from docs]
```

## Extraction Protocol

1. WebFetch the API documentation URL
2. Extract ALL 9 fields above
3. Quote exact text (no paraphrasing)
4. Show extraction to user
5. ONLY THEN implement

## Implementation Blockers

**You MUST verify before proceeding:**
- [ ] HTTP method copied from docs
- [ ] Endpoint path exact match
- [ ] Content-Type verified
- [ ] Field names match exactly
- [ ] File format confirmed

## STOP Protocol

**IF docs unavailable:**
- STOP immediately
- Request docs URL from user
- AWAIT URL before proceeding

## Common Extraction Failures

**You MUST NEVER:**
- ❌ Guess HTTP method from similar endpoints
- ❌ Assume field names from other APIs
- ❌ Infer content type from file extension
- ❌ Pattern-match from existing code
- ❌ Proceed without completing extraction

**You MUST ALWAYS:**
- ✅ WebFetch and read actual docs
- ✅ Quote specifications exactly
- ✅ Show extraction before coding
- ✅ Stop if docs unavailable
- ✅ Match implementation to extraction
