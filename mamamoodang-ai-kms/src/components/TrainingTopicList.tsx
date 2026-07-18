import { MessageSquareText, Plus, Search } from 'lucide-react';
import type { KnowledgeCategory, KnowledgeTopic, TopicFilters } from '../types/knowledge';
import { formatDate } from '../lib/utils';
import { Badge } from './ui/Badge';
import { Button } from './ui/Button';
import { Input, Select } from './ui/Field';

type TrainingTopicListProps = {
  topics: KnowledgeTopic[];
  categories: KnowledgeCategory[];
  filters: TopicFilters;
  selectedId: string | null;
  onFiltersChange: (filters: TopicFilters) => void;
  onSelect: (id: string) => void;
  onNew: () => void;
};

export function TrainingTopicList({ topics, categories, filters, selectedId, onFiltersChange, onSelect, onNew }: TrainingTopicListProps) {
  return (
    <aside className="relative flex min-h-[calc(100vh-132px)] flex-col rounded-2xl border border-border bg-card text-card-foreground shadow-soft">
      <div className="border-b border-border p-5">
        <div className="flex items-start justify-between gap-3">
          <div>
            <p className="text-sm font-bold text-primary">Training Topics</p>
            <h2 className="mt-1 text-2xl font-bold">Knowledge conversations</h2>
            <p className="mt-1 text-sm text-muted-foreground">{topics.length} matching topics</p>
          </div>
          <Button className="rounded-full px-4" onClick={onNew}>
            <Plus size={16} /> New
          </Button>
        </div>

        <div className="mt-5 grid gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" size={17} />
            <Input
              className="pl-9"
              value={filters.query}
              placeholder="Search title, category, conversation..."
              onChange={(event) => onFiltersChange({ ...filters, query: event.target.value })}
            />
          </div>
          <Select value={filters.categoryId} onChange={(event) => onFiltersChange({ ...filters, categoryId: event.target.value })}>
            <option value="">All categories</option>
            {categories.map((category) => (
              <option key={category.id} value={category.id}>
                {category.name}
              </option>
            ))}
          </Select>
        </div>
      </div>

      <div className="flex-1 space-y-3 overflow-y-auto p-4 pb-24">
        {topics.map((topic) => {
          const selected = topic.id === selectedId;
          return (
            <button
              key={topic.id}
              className={`w-full rounded-2xl border p-4 text-left transition ${
                selected
                  ? 'border-primary bg-primary/10 shadow-soft'
                  : 'border-border bg-background hover:border-primary/60 hover:bg-primary/5'
              }`}
              onClick={() => onSelect(topic.id)}
            >
              <div className="flex gap-3">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-primary/15 text-primary">
                  <MessageSquareText size={20} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <h3 className="truncate text-base font-bold text-foreground">{topic.title}</h3>
                    <Badge className="shrink-0">{topic.messageCount} msgs</Badge>
                  </div>
                  <p className="mt-1 text-sm font-semibold text-primary">{topic.categoryName}</p>
                  <p className="mt-2 text-xs leading-5 text-muted-foreground">Updated {formatDate(topic.updatedAt)}</p>
                </div>
              </div>
            </button>
          );
        })}
        {!topics.length && (
          <div className="rounded-2xl border border-dashed border-border p-6 text-center text-sm leading-6 text-muted-foreground">
            No topic matched your search. Start a new knowledge conversation when you are ready.
          </div>
        )}
      </div>

      <div className="pointer-events-none absolute inset-x-0 bottom-0 flex justify-center bg-gradient-to-t from-card via-card to-transparent p-5 pt-10">
        <Button className="pointer-events-auto rounded-full px-6 shadow-soft" onClick={onNew}>
          <Plus size={17} /> New Knowledge
        </Button>
      </div>
    </aside>
  );
}
