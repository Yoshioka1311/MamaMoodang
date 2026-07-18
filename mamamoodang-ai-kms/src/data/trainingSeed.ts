import type { KnowledgeTopic, TopicChatMessage } from '../types/knowledge';

const now = '2026-07-17T10:00:00.000Z';

export const seedTopics: KnowledgeTopic[] = [
  {
    id: 'topic-banana-gdm',
    title: 'Banana and GDM',
    categoryId: 'cat-nutrition',
    categoryName: 'Nutrition',
    keywords: ['banana', 'gestational diabetes', 'fruit', 'glucose'],
    messageCount: 4,
    createdAt: '2026-07-14T09:00:00.000Z',
    updatedAt: '2026-07-17T09:10:00.000Z',
  },
  {
    id: 'topic-pm25-pregnancy',
    title: 'PM2.5 Pregnancy',
    categoryId: 'cat-environment',
    categoryName: 'Environmental Health',
    keywords: ['pm2.5', 'pregnancy', 'air quality'],
    messageCount: 3,
    createdAt: '2026-07-15T08:00:00.000Z',
    updatedAt: '2026-07-17T08:45:00.000Z',
  },
  {
    id: 'topic-stress-support',
    title: 'Stress Support',
    categoryId: 'cat-mental',
    categoryName: 'Mental Health',
    keywords: ['stress', 'mood', 'buddy care'],
    messageCount: 3,
    createdAt: '2026-07-15T11:00:00.000Z',
    updatedAt: '2026-07-16T15:20:00.000Z',
  },
  {
    id: 'topic-breakfast-guide',
    title: 'Breakfast Guide',
    categoryId: 'cat-nutrition',
    categoryName: 'Nutrition',
    keywords: ['breakfast', 'protein', 'carbohydrate'],
    messageCount: 2,
    createdAt: '2026-07-16T09:00:00.000Z',
    updatedAt: '2026-07-16T11:30:00.000Z',
  },
  {
    id: 'topic-heat-index',
    title: 'Heat Index',
    categoryId: 'cat-environment',
    categoryName: 'Environmental Health',
    keywords: ['heat index', 'hydration', 'temperature'],
    messageCount: 2,
    createdAt: '2026-07-16T12:00:00.000Z',
    updatedAt: '2026-07-16T13:15:00.000Z',
  },
  {
    id: 'topic-exercise',
    title: 'Exercise During Pregnancy',
    categoryId: 'cat-gdm',
    categoryName: 'Gestational Diabetes',
    keywords: ['exercise', 'walking', 'pregnancy'],
    messageCount: 2,
    createdAt: '2026-07-16T14:00:00.000Z',
    updatedAt: now,
  },
];

export const seedTopicMessages: TopicChatMessage[] = [
  {
    id: 'msg-banana-1',
    topicId: 'topic-banana-gdm',
    role: 'user',
    message: 'Create chatbot knowledge about whether pregnant mothers with GDM can eat bananas.',
    createdAt: '2026-07-17T09:00:00.000Z',
  },
  {
    id: 'msg-banana-2',
    topicId: 'topic-banana-gdm',
    role: 'assistant',
    message:
      'Yes. Draft knowledge: Bananas can fit into some gestational diabetes meal plans when the portion is controlled and paired with protein or healthy fat. Buddy should encourage users to check their own glucose response and follow their care team plan.',
    createdAt: '2026-07-17T09:02:00.000Z',
  },
  {
    id: 'msg-banana-3',
    topicId: 'topic-banana-gdm',
    role: 'user',
    message: 'Make it patient friendly and add Buddy tone.',
    createdAt: '2026-07-17T09:05:00.000Z',
  },
  {
    id: 'msg-banana-4',
    topicId: 'topic-banana-gdm',
    role: 'assistant',
    message:
      'Buddy response: "A small banana can be okay for some moms, especially with yogurt, nuts, or eggs. Let us keep the portion gentle and check how your body responds after eating." Safety note: avoid promising that any food is always safe for every user.',
    createdAt: '2026-07-17T09:10:00.000Z',
  },
  {
    id: 'msg-pm25-1',
    topicId: 'topic-pm25-pregnancy',
    role: 'user',
    message: 'Summarize PM2.5 guidance for pregnant users.',
    createdAt: '2026-07-17T08:40:00.000Z',
  },
  {
    id: 'msg-pm25-2',
    topicId: 'topic-pm25-pregnancy',
    role: 'assistant',
    message:
      'When PM2.5 is elevated, Buddy should recommend reducing prolonged outdoor activity, choosing indoor movement, closing windows when outdoor air is poor, and contacting a healthcare provider for shortness of breath, dizziness, chest pain, or severe symptoms.',
    createdAt: '2026-07-17T08:42:00.000Z',
  },
  {
    id: 'msg-pm25-3',
    topicId: 'topic-pm25-pregnancy',
    role: 'assistant',
    message:
      'Chatbot boundary: keep claims cautious. Do not diagnose respiratory problems. Offer practical protection and escalation advice.',
    createdAt: '2026-07-17T08:45:00.000Z',
  },
  {
    id: 'msg-stress-1',
    topicId: 'topic-stress-support',
    role: 'user',
    message: 'Create Buddy responses for a sad or stressed mood check-in.',
    createdAt: '2026-07-16T15:12:00.000Z',
  },
  {
    id: 'msg-stress-2',
    topicId: 'topic-stress-support',
    role: 'assistant',
    message:
      'Buddy should validate first: "I am here with you today. You do not have to carry this alone." Then offer one small step such as breathing, water, rest, or messaging someone trusted.',
    createdAt: '2026-07-16T15:16:00.000Z',
  },
  {
    id: 'msg-stress-3',
    topicId: 'topic-stress-support',
    role: 'assistant',
    message:
      'Safety boundary: Buddy should not diagnose anxiety or depression. If distress is severe, persistent, or includes thoughts of harm, encourage urgent professional or local emergency support.',
    createdAt: '2026-07-16T15:20:00.000Z',
  },
];
