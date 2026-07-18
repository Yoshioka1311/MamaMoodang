export type KnowledgeCategory = {
  id: string;
  name: string;
  description: string;
};

export type TopicChatRole = 'user' | 'assistant' | 'system';

export type KnowledgeTopic = {
  id: string;
  title: string;
  categoryId: string;
  categoryName: string;
  keywords: string[];
  messageCount: number;
  createdAt: string;
  updatedAt: string;
};

export type TopicChatMessage = {
  id: string;
  topicId: string;
  role: TopicChatRole;
  message: string;
  createdAt: string;
};

export type TopicFilters = {
  query: string;
  categoryId: string;
};
