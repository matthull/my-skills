---
name: ui-state-management
description: >-
  Zustand + MMKV for UI-only state management. This skill should be used when
  managing ephemeral UI state (theme, modals, navigation, form drafts) that
  doesn't sync between devices. Handles 10% of app state per the 90/10 principle.
  Relevant during IMPLEMENT phase for features requiring local-only UI state.
---

# UI State Management

Zustand handles lightweight, UI-only state. This is 10% of the app's state.

## 90/10 Principle

```
┌─────────────────────────────────────────────────────────────┐
│                    State Responsibilities                   │
├─────────────────────────────────────────────────────────────┤
│  PowerSync (90%)               │  Zustand (10%)             │
│  ─────────────────────────────│────────────────────────────│
│  • All business data          │  • Current theme           │
│  • Tasks, appointments        │  • Active business ID      │
│  • Invoices, customers        │  • UI modal states         │
│  • Equipment, inventory       │  • Form draft state        │
│  • Offline queue              │  • Navigation state        │
└─────────────────────────────────────────────────────────────┘
```

## What Belongs in Zustand (10%)

| State Type | Examples |
|------------|----------|
| User preferences | Theme (light/dark/system), language |
| Session context | Active business ID, current user role |
| UI state | Modal visibility, drawer open/closed |
| Transient state | Form drafts before save, search filters |
| Navigation | Deep link state, tab history |

**Key principle:** If data doesn't need to sync between devices or persist across app reinstalls, consider Zustand.

## Implementation Reference

Stores live in `src/stores/`. Read these files for established patterns:

| File | Purpose | Read When |
|------|---------|-----------|
| `src/stores/uiPreferencesStore.ts` | Persisted store with MMKV adapter pattern | Creating new persisted stores |

## Key Implementation Notes

**MMKV v4 API** (current version):
- Import: `import { createMMKV } from 'react-native-mmkv'`
- Initialize: `const storage = createMMKV({ id: 'unique-id' })`
- Remove: `storage.remove('key')` (not `delete()`)

**Selector pattern** for performance:
```typescript
// Selects only what component needs (fewer re-renders)
const theme = useUIPreferencesStore((state) => state.theme);
```

## Testing Reference

See `__tests__/stores/` for store test patterns:
- Reset store in beforeEach: `useStore.setState({ ... })`
- Access state directly: `useStore.getState()`
- Call actions: `useStore.getState().actionName()`

## Decision: Zustand vs PowerSync

| Question | Answer |
|----------|--------|
| Does it sync between devices? | PowerSync |
| Does it persist across reinstalls? | PowerSync (or Zustand + MMKV if local-only) |
| Is it business data? | PowerSync |
| Is it user preference? | Zustand + MMKV |
| Is it transient UI state? | Zustand (no persist) |
| Does it need offline support? | PowerSync |

## Anti-Patterns

- **NEVER** store business data in Zustand - use PowerSync
- **NEVER** use useState for global state that multiple components need
- **NEVER** create massive stores - split by domain (preferences, session, modals)
- **NEVER** mutate state directly - always use `set()` from Zustand
- **NEVER** forget to reset stores in tests - they persist between test cases
