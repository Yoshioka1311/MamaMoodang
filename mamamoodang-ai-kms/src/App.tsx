import { BrainCircuit, Moon, ShieldCheck, Sun } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { NewKnowledgeDialog } from './components/NewKnowledgeDialog';
import { TrainingChatWorkspace } from './components/TrainingChatWorkspace';
import { TrainingTopicList } from './components/TrainingTopicList';
import { Button } from './components/ui/Button';
import { categories as fallbackCategories } from './data/seed';
import { createTrainingRepository } from './repositories/createTrainingRepository';
import { createSupabaseBrowserClient } from './repositories/supabaseTrainingRepository';
import { generateTrainingResponse } from './services/trainingAssistant';
import type { KnowledgeCategory, KnowledgeTopic, TopicChatMessage, TopicFilters } from './types/knowledge';

export default function App() {
  const supabase = useMemo(() => createSupabaseBrowserClient(), []);
  const repository = useMemo(() => createTrainingRepository(supabase), [supabase]);
  const supabaseEnabled = Boolean(supabase);

  const [darkMode, setDarkMode] = useState(false);
  const [filters, setFilters] = useState<TopicFilters>({ query: '', categoryId: '' });
  const [categories, setCategories] = useState<KnowledgeCategory[]>([]);
  const [topics, setTopics] = useState<KnowledgeTopic[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [selectedTopic, setSelectedTopic] = useState<KnowledgeTopic | null>(null);
  const [messages, setMessages] = useState<TopicChatMessage[]>([]);
  const [newDialogOpen, setNewDialogOpen] = useState(false);
  const [sending, setSending] = useState(false);
  const [loadError, setLoadError] = useState('');

  const topicCountLabel = useMemo(() => `${topics.length} training ${topics.length === 1 ? 'topic' : 'topics'}`, [topics.length]);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', darkMode);
  }, [darkMode]);

  async function refreshTopics(nextSelectedId = selectedId) {
    try {
      setLoadError('');
      const [nextCategories, nextTopics] = await Promise.all([repository.listCategories(), repository.listTopics(filters)]);
      setCategories(nextCategories.length ? nextCategories : fallbackCategories);
      setTopics(nextTopics);

      if (!nextSelectedId && nextTopics[0]) {
        setSelectedId(nextTopics[0].id);
        return;
      }

      if (nextSelectedId && !nextTopics.some((topic) => topic.id === nextSelectedId)) {
        setSelectedId(nextTopics[0]?.id ?? null);
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unable to load Supabase training data.';
      setLoadError(message);
      setCategories([]);
      setTopics([]);
      setSelectedId(null);
    }
  }

  async function refreshConversation(topicId: string | null) {
    if (!topicId) {
      setSelectedTopic(null);
      setMessages([]);
      return;
    }

    try {
      setLoadError('');
      const [topic, nextMessages] = await Promise.all([repository.getTopic(topicId), repository.listMessages(topicId)]);
      setSelectedTopic(topic);
      setMessages(nextMessages);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unable to load this training conversation.';
      setLoadError(message);
      setSelectedTopic(null);
      setMessages([]);
    }
  }

  useEffect(() => {
    void refreshTopics();
  }, [filters]);

  useEffect(() => {
    void refreshConversation(selectedId);
  }, [selectedId]);

  async function createTopic(title: string, categoryId: string) {
    try {
      const topic = await repository.createTopic(title, categoryId);
      setNewDialogOpen(false);
      setSelectedId(topic.id);
      await refreshTopics(topic.id);
      await refreshConversation(topic.id);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to create this topic.');
    }
  }

  async function sendMessage(message: string) {
    if (!selectedTopic || sending) return;

    setSending(true);
    try {
      const userMessage = await repository.addMessage(selectedTopic.id, 'user', message);
      const historyAfterUser = [...messages, userMessage];
      setMessages(historyAfterUser);

      const response = generateTrainingResponse(selectedTopic, historyAfterUser, message);
      await new Promise((resolve) => window.setTimeout(resolve, 450));
      const assistantMessage = await repository.addMessage(selectedTopic.id, 'assistant', response);
      setMessages([...historyAfterUser, assistantMessage]);

      await refreshTopics(selectedTopic.id);
      await refreshConversation(selectedTopic.id);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to save this message.');
    } finally {
      setSending(false);
    }
  }

  return (
    <main className="min-h-screen bg-background px-4 py-5 text-foreground lg:px-6">
      <div className="mx-auto flex max-w-[1680px] flex-col gap-5">
        <header className="flex flex-col gap-4 rounded-2xl border border-border bg-card px-5 py-4 shadow-soft lg:flex-row lg:items-center lg:justify-between">
          <div>
            <div className="flex items-center gap-2 text-sm font-bold text-primary">
              <ShieldCheck size={17} /> Internal AI Training Workspace
            </div>
            <h1 className="mt-1 text-2xl font-bold tracking-normal">Mamamoodang AI Knowledge Training</h1>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-muted-foreground">
              Build chatbot knowledge through saved conversations. Choose a topic, chat naturally with the medical knowledge assistant,
              and every message becomes part of the training base automatically.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <div className="rounded-full border border-border bg-background px-4 py-2 text-sm font-semibold text-muted-foreground">
              {supabaseEnabled ? 'Supabase shared storage' : 'Browser preview storage'}
            </div>
            <div className="flex items-center gap-2 rounded-full border border-border bg-background px-4 py-2 text-sm font-semibold text-muted-foreground">
              <BrainCircuit size={16} className="text-primary" /> {topicCountLabel}
            </div>
            <Button variant="secondary" onClick={() => setDarkMode((value) => !value)}>
              {darkMode ? <Sun size={16} /> : <Moon size={16} />}
              {darkMode ? 'Light' : 'Dark'}
            </Button>
          </div>
        </header>

        {loadError && (
          <div className="rounded-2xl border border-destructive/30 bg-destructive/10 px-5 py-4 text-sm font-semibold text-destructive">
            {loadError}
          </div>
        )}

        <div className="grid gap-5 xl:grid-cols-[420px_minmax(0,1fr)]">
          <TrainingTopicList
            topics={topics}
            categories={categories}
            filters={filters}
            selectedId={selectedId}
            onFiltersChange={setFilters}
            onSelect={setSelectedId}
            onNew={() => setNewDialogOpen(true)}
          />
          <TrainingChatWorkspace
            topic={selectedTopic}
            messages={messages}
            sending={sending}
            onSend={sendMessage}
          />
        </div>
      </div>

      {newDialogOpen && (
        <NewKnowledgeDialog
          categories={categories}
          onCancel={() => setNewDialogOpen(false)}
          onCreate={createTopic}
        />
      )}
    </main>
  );
}
