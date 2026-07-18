import { Bot, Clock, Send, Sparkles, Trash2, UserRound } from 'lucide-react';
import type { FormEvent } from 'react';
import { useEffect, useRef, useState } from 'react';
import { cn, formatDate } from '../lib/utils';
import type { KnowledgeTopic, TopicChatMessage } from '../types/knowledge';
import { Button } from './ui/Button';

type TrainingChatWorkspaceProps = {
  topic: KnowledgeTopic | null;
  messages: TopicChatMessage[];
  sending: boolean;
  onSend: (message: string) => Promise<void>;
  onDelete?: () => Promise<void>;
};

function renderMarkdown(value: string) {
  const lines = value.split('\n');
  return lines.map((line, index) => {
    const key = `${index}-${line}`;
    if (!line.trim()) return <br key={key} />;
    if (line.startsWith('## ')) return <h3 key={key} className="mt-3 text-lg font-bold">{line.replace('## ', '')}</h3>;
    if (line.startsWith('**') && line.endsWith('**')) return <p key={key} className="font-bold">{line.replace(/\*\*/g, '')}</p>;
    if (line.startsWith('- ')) return <p key={key} className="pl-4 text-sm leading-7 before:mr-2 before:content-['-']">{line.replace('- ', '')}</p>;
    return (
      <p key={key} className="text-sm leading-7">
        {line.split(/(\*\*[^*]+\*\*)/g).map((part, partIndex) =>
          part.startsWith('**') && part.endsWith('**') ? (
            <strong key={partIndex}>{part.replace(/\*\*/g, '')}</strong>
          ) : (
            <span key={partIndex}>{part}</span>
          ),
        )}
      </p>
    );
  });
}

export function TrainingChatWorkspace({ topic, messages, sending, onSend, onDelete }: TrainingChatWorkspaceProps) {
  const [draft, setDraft] = useState('');
  const scrollRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: 'smooth' });
  }, [messages, topic?.id, sending]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const message = draft.trim();
    if (!message || !topic || sending) return;
    setDraft('');
    await onSend(message);
  }

  if (!topic) {
    return (
      <section className="flex min-h-[calc(100vh-132px)] items-center justify-center rounded-2xl border border-border bg-card p-8 text-center shadow-soft">
        <div className="max-w-md">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/15 text-primary">
            <Sparkles size={24} />
          </div>
          <h2 className="mt-5 text-2xl font-bold">Choose or create a knowledge topic</h2>
          <p className="mt-2 text-sm leading-6 text-muted-foreground">
            Each topic is a saved AI training conversation. The knowledge base grows from the chat history automatically.
          </p>
        </div>
      </section>
    );
  }

  return (
    <section className="flex min-h-[calc(100vh-132px)] flex-col rounded-2xl border border-border bg-card text-card-foreground shadow-soft">
      <header className="flex flex-col gap-4 border-b border-border p-5 lg:flex-row lg:items-center lg:justify-between">
        <div className="min-w-0">
          <p className="text-sm font-bold text-primary">AI Knowledge Training</p>
          <h2 className="mt-1 truncate text-2xl font-bold">{topic.title}</h2>
          <div className="mt-2 flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
            <span>{topic.categoryName}</span>
            <span className="flex items-center gap-1">
              <Clock size={14} /> Updated {formatDate(topic.updatedAt)}
            </span>
            <span>{messages.length} saved messages</span>
          </div>
        </div>
        {onDelete && (
          <Button
            variant="danger"
            onClick={() => {
              if (window.confirm('Delete this knowledge conversation?\n\nThis action cannot be undone.')) void onDelete();
            }}
          >
            <Trash2 size={16} /> Delete
          </Button>
        )}
      </header>

      <div ref={scrollRef} className="flex-1 overflow-y-auto bg-gradient-to-b from-background to-card p-5">
        <div className="mx-auto flex max-w-4xl flex-col gap-5">
          {messages.length === 0 && (
            <div className="rounded-3xl border border-dashed border-border bg-card/80 p-6 text-center">
              <Sparkles className="mx-auto text-primary" size={24} />
              <h3 className="mt-3 text-xl font-bold">Start chatting to train this topic</h3>
              <p className="mt-2 text-sm leading-6 text-muted-foreground">
                Try Thai or English prompts: summarize this topic, create FAQs, write Buddy responses, simplify for patients, or convert this into chatbot knowledge.
              </p>
            </div>
          )}

          {messages.map((message) => {
            const isUser = message.role === 'user';
            return (
              <article key={message.id} className={cn('flex gap-3', isUser && 'flex-row-reverse')}>
                <div
                  className={cn(
                    'flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl',
                    isUser ? 'bg-primary text-primary-foreground' : 'bg-muted text-foreground',
                  )}
                >
                  {isUser ? <UserRound size={18} /> : <Bot size={18} />}
                </div>
                <div className={cn('max-w-[82%] rounded-3xl px-5 py-4', isUser ? 'bg-primary text-primary-foreground' : 'bg-card border border-border')}>
                  <div className="mb-2 flex items-center justify-between gap-3 text-xs font-semibold opacity-80">
                    <span>{isUser ? 'Admin' : 'Medical Knowledge AI'}</span>
                    <span>{formatDate(message.createdAt)}</span>
                  </div>
                  <div className={cn('space-y-1', isUser ? 'text-primary-foreground' : 'text-foreground')}>{renderMarkdown(message.message)}</div>
                </div>
              </article>
            );
          })}

          {sending && (
            <article className="flex gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-muted text-foreground">
                <Bot size={18} />
              </div>
              <div className="rounded-3xl border border-border bg-card px-5 py-4 text-sm text-muted-foreground">
                AI is writing and auto-saving...
              </div>
            </article>
          )}
        </div>
      </div>

      <form onSubmit={submit} className="border-t border-border bg-card p-4">
        <div className="mx-auto flex max-w-4xl items-end gap-3 rounded-3xl border border-border bg-background p-2 shadow-soft">
          <textarea
            className="max-h-40 min-h-12 flex-1 resize-none bg-transparent px-4 py-3 text-sm leading-6 text-foreground outline-none placeholder:text-muted-foreground"
            value={draft}
            placeholder="Message the medical knowledge AI in Thai or English..."
            onChange={(event) => setDraft(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                event.currentTarget.form?.requestSubmit();
              }
            }}
          />
          <Button type="submit" className="h-12 rounded-2xl px-5" disabled={!draft.trim() || sending}>
            <Send size={17} /> Send
          </Button>
        </div>
      </form>
    </section>
  );
}
