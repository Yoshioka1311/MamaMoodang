import type { FormEvent } from 'react';
import { useState } from 'react';
import type { KnowledgeCategory } from '../types/knowledge';
import { Button } from './ui/Button';
import { Input, Label, Select } from './ui/Field';

type NewKnowledgeDialogProps = {
  categories: KnowledgeCategory[];
  onCancel: () => void;
  onCreate: (title: string, categoryId: string) => Promise<void>;
};

export function NewKnowledgeDialog({ categories, onCancel, onCreate }: NewKnowledgeDialogProps) {
  const [title, setTitle] = useState('');
  const [categoryId, setCategoryId] = useState(categories[0]?.id ?? '');
  const [creating, setCreating] = useState(false);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!title.trim()) return;
    setCreating(true);
    await onCreate(title.trim(), categoryId);
    setCreating(false);
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/35 px-4 backdrop-blur-sm">
      <form onSubmit={submit} className="w-full max-w-md rounded-2xl border border-border bg-card p-5 text-card-foreground shadow-soft">
        <div>
          <p className="text-sm font-bold text-primary">New Knowledge</p>
          <h2 className="mt-1 text-2xl font-bold">Start a training conversation</h2>
          <p className="mt-2 text-sm leading-6 text-muted-foreground">Create a topic, then chat naturally with the AI to build the knowledge.</p>
        </div>

        <div className="mt-5 space-y-4">
          <div className="space-y-1.5">
            <Label>Knowledge Title</Label>
            <Input autoFocus value={title} placeholder="Example: Banana and GDM" onChange={(event) => setTitle(event.target.value)} />
          </div>
          <div className="space-y-1.5">
            <Label>Category</Label>
            <Select value={categoryId} onChange={(event) => setCategoryId(event.target.value)}>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </Select>
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-3">
          <Button type="button" variant="secondary" onClick={onCancel}>
            Cancel
          </Button>
          <Button type="submit" disabled={!title.trim() || creating}>
            Create
          </Button>
        </div>
      </form>
    </div>
  );
}
