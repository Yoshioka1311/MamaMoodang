import { categories } from '../data/seed';
import { seedTopicMessages, seedTopics } from '../data/trainingSeed';
import { newId } from '../lib/utils';
import type { KnowledgeCategory, KnowledgeTopic, TopicChatMessage, TopicFilters, TopicChatRole } from '../types/knowledge';
import type { TrainingRepository } from './trainingRepository';

const TOPICS_KEY = 'mamamoodang-kms-training-topics-v1';
const MESSAGES_KEY = 'mamamoodang-kms-training-messages-v1';

function readTopics() {
  const raw = localStorage.getItem(TOPICS_KEY);
  if (!raw) {
    localStorage.setItem(TOPICS_KEY, JSON.stringify(seedTopics));
    return seedTopics;
  }
  return JSON.parse(raw) as KnowledgeTopic[];
}

function writeTopics(topics: KnowledgeTopic[]) {
  localStorage.setItem(TOPICS_KEY, JSON.stringify(topics));
}

function readMessages() {
  const raw = localStorage.getItem(MESSAGES_KEY);
  if (!raw) {
    localStorage.setItem(MESSAGES_KEY, JSON.stringify(seedTopicMessages));
    return seedTopicMessages;
  }
  return JSON.parse(raw) as TopicChatMessage[];
}

function writeMessages(messages: TopicChatMessage[]) {
  localStorage.setItem(MESSAGES_KEY, JSON.stringify(messages));
}

function findCategory(categoryId: string): KnowledgeCategory {
  return categories.find((category) => category.id === categoryId) ?? categories[0];
}

function extractKeywords(title: string, messages: TopicChatMessage[]) {
  const words = `${title} ${messages.map((message) => message.message).join(' ')}`
    .toLowerCase()
    .replace(/[^a-z0-9.\s]/g, ' ')
    .split(/\s+/)
    .filter((word) => word.length > 3 && !['this', 'that', 'with', 'from', 'should', 'knowledge'].includes(word));

  return Array.from(new Set(words)).slice(0, 12);
}

function matchesTopic(topic: KnowledgeTopic, messages: TopicChatMessage[], filters: TopicFilters) {
  const query = filters.query.trim().toLowerCase();
  const topicMessages = messages.filter((message) => message.topicId === topic.id);
  const haystack = [topic.title, topic.categoryName, topic.keywords.join(' '), topicMessages.map((message) => message.message).join(' ')]
    .join(' ')
    .toLowerCase();

  return (!query || haystack.includes(query)) && (!filters.categoryId || topic.categoryId === filters.categoryId);
}

function withCounts(topic: KnowledgeTopic, messages: TopicChatMessage[]) {
  const topicMessages = messages.filter((message) => message.topicId === topic.id);
  return {
    ...topic,
    messageCount: topicMessages.length,
    keywords: extractKeywords(topic.title, topicMessages),
  };
}

export class TopicRepository implements TrainingRepository {
  async listCategories() {
    return categories;
  }

  async listTopics(filters: TopicFilters) {
    const messages = readMessages();
    return readTopics()
      .map((topic) => withCounts(topic, messages))
      .filter((topic) => matchesTopic(topic, messages, filters))
      .sort((a, b) => Date.parse(b.updatedAt) - Date.parse(a.updatedAt));
  }

  async getTopic(id: string) {
    const messages = readMessages();
    const topic = readTopics().find((item) => item.id === id);
    return topic ? withCounts(topic, messages) : null;
  }

  async createTopic(title: string, categoryId: string) {
    const now = new Date().toISOString();
    const category = findCategory(categoryId);
    const topic: KnowledgeTopic = {
      id: newId('topic'),
      title,
      categoryId: category.id,
      categoryName: category.name,
      keywords: extractKeywords(title, []),
      messageCount: 0,
      createdAt: now,
      updatedAt: now,
    };

    writeTopics([topic, ...readTopics()]);
    return topic;
  }

  async deleteTopic(id: string) {
    writeTopics(readTopics().filter((topic) => topic.id !== id));
    writeMessages(readMessages().filter((message) => message.topicId !== id));
  }

  async listMessages(topicId: string) {
    return readMessages()
      .filter((message) => message.topicId === topicId)
      .sort((a, b) => Date.parse(a.createdAt) - Date.parse(b.createdAt));
  }

  async addMessage(topicId: string, role: TopicChatRole, message: string) {
    const now = new Date().toISOString();
    const nextMessage: TopicChatMessage = {
      id: newId('msg'),
      topicId,
      role,
      message,
      createdAt: now,
    };
    const nextMessages = [...readMessages(), nextMessage];
    writeMessages(nextMessages);
    writeTopics(
      readTopics().map((topic) => {
        if (topic.id !== topicId) return topic;
        const topicMessages = nextMessages.filter((item) => item.topicId === topicId);
        return {
          ...topic,
          updatedAt: now,
          messageCount: topicMessages.length,
          keywords: extractKeywords(topic.title, topicMessages),
        };
      }),
    );
    return nextMessage;
  }
}
