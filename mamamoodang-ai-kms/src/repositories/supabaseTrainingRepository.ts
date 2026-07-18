import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import type { KnowledgeCategory, KnowledgeTopic, TopicChatMessage, TopicChatRole, TopicFilters } from '../types/knowledge';
import type { TrainingRepository } from './trainingRepository';

export function createSupabaseBrowserClient() {
  const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
  const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

  if (!url || !anonKey) return null;
  return createClient(url, anonKey);
}

function mapTopic(row: any): KnowledgeTopic {
  return {
    id: row.id,
    title: row.title,
    categoryId: row.category_id ?? '',
    categoryName: row.knowledge_categories?.name ?? 'Uncategorized',
    keywords: row.keywords ?? [],
    messageCount: row.chat_messages?.[0]?.count ?? row.message_count ?? 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapMessage(row: any): TopicChatMessage {
  return {
    id: row.id,
    topicId: row.topic_id,
    role: row.role,
    message: row.message,
    createdAt: row.created_at,
  };
}

export class SupabaseTrainingRepository implements TrainingRepository {
  constructor(private readonly client: SupabaseClient) {}

  async listCategories(): Promise<KnowledgeCategory[]> {
    const { data, error } = await this.client.from('knowledge_categories').select('id,name,description').order('name');
    if (error) throw error;
    return data ?? [];
  }

  async listTopics(filters: TopicFilters): Promise<KnowledgeTopic[]> {
    let query = this.client
      .from('knowledge_topics')
      .select('*, knowledge_categories(name), chat_messages(count)')
      .order('updated_at', { ascending: false });

    if (filters.categoryId) query = query.eq('category_id', filters.categoryId);

    const { data, error } = await query;
    if (error) throw error;

    const topics = (data ?? []).map(mapTopic);
    if (!filters.query.trim()) return topics;

    const value = filters.query.trim().toLowerCase();
    const topicIds = topics.map((topic) => topic.id);
    const { data: matchedMessages } = await this.client
      .from('chat_messages')
      .select('topic_id,message')
      .in('topic_id', topicIds.length ? topicIds : ['00000000-0000-0000-0000-000000000000'])
      .ilike('message', `%${value}%`);

    const messageTopicIds = new Set((matchedMessages ?? []).map((message) => message.topic_id));
    return topics.filter((topic) => {
      const topicText = `${topic.title} ${topic.categoryName} ${topic.keywords.join(' ')}`.toLowerCase();
      return topicText.includes(value) || messageTopicIds.has(topic.id);
    });
  }

  async getTopic(id: string): Promise<KnowledgeTopic | null> {
    const { data, error } = await this.client
      .from('knowledge_topics')
      .select('*, knowledge_categories(name), chat_messages(count)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data ? mapTopic(data) : null;
  }

  async createTopic(title: string, categoryId: string): Promise<KnowledgeTopic> {
    const { data, error } = await this.client
      .from('knowledge_topics')
      .insert({ title, category_id: categoryId, keywords: [] })
      .select('*, knowledge_categories(name), chat_messages(count)')
      .single();
    if (error) throw error;
    return mapTopic(data);
  }

  async deleteTopic(id: string): Promise<void> {
    const { error } = await this.client.from('knowledge_topics').delete().eq('id', id);
    if (error) throw error;
  }

  async listMessages(topicId: string): Promise<TopicChatMessage[]> {
    const { data, error } = await this.client
      .from('chat_messages')
      .select('id,topic_id,role,message,created_at')
      .eq('topic_id', topicId)
      .order('created_at', { ascending: true });
    if (error) throw error;
    return (data ?? []).map(mapMessage);
  }

  async addMessage(topicId: string, role: TopicChatRole, message: string): Promise<TopicChatMessage> {
    const { data, error } = await this.client
      .from('chat_messages')
      .insert({ topic_id: topicId, role, message })
      .select('id,topic_id,role,message,created_at')
      .single();
    if (error) throw error;
    return mapMessage(data);
  }
}
