# Full-Stack CRUD Pattern

## The 4-Layer Pattern

```
Backend Router → Frontend API → Store Action → Page Component
(router/*.py)    (lib/api.ts)   (dashboardStore) (pages/*Page.tsx)
```

Every new operation touches all 4 layers.

### 1. Backend: Add endpoint
```python
@router.delete("/{id}", status_code=204)
def delete_entity(id: str, db = Depends(get_db)):
    service.delete(id)
```

### 2. Frontend API: Add function
```typescript
deleteEntity: (id: string) => request<void>(`/api/entity/${id}`, { method: "DELETE" }),
```

### 3. Store: Add interface + implementation
```typescript
deleteEntity: (id: string) => Promise<void>;
async deleteEntity(id) { await api.deleteEntity(id); await get().loadDashboard(); }
```

### 4. Page: Add button + confirmation dialog
- Import `Trash2` from lucide-react
- Destructure from store
- Add `confirmDelete` state
- Add handler + button + confirmation dialog

## Cascade Behavior

| Entity | DELETE cascade |
|--------|----------------|
| Funnels | Steps deleted via FK cascade |
| Clients | Funnels→steps + tickets deleted |
| Templates | Template deleted, funnel references set NULL |
