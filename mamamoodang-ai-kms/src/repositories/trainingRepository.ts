import type { KnowledgeCategory, KnowledgeTopic, TopicChatMessage, TopicChatRole, TopicFilters } from '../types/knowledge';

export interface TrainingRepository {
  listCategories(): Promise<KnowledgeCategory[]>;
  listTopics(filters: TopicFilters): Promise<KnowledgeTopic[]>;
  getTopic(id: string): Promise<KnowledgeTopic | null>;
  createTopic(title: string, categoryId: string): Promise<KnowledgeTopic>;
  deleteTopic(id: string): Promise<void>;
  listMessages(topicId: string): Promise<TopicChatMessage[]>;
  addMessage(topicId: string, role: TopicChatRole, message: string): Promise<TopicChatMessage>;
}
