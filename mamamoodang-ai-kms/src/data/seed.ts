import type { KnowledgeCategory } from '../types/knowledge';

export const categories: KnowledgeCategory[] = [
  { id: 'cat-gdm', name: 'Gestational Diabetes', description: 'Core GDM guidance and safety boundaries.' },
  { id: 'cat-nutrition', name: 'Nutrition', description: 'Food, meal planning, GI, and daily nutrition support.' },
  { id: 'cat-mental', name: 'Mental Health', description: 'Emotional support and non-diagnostic coping guidance.' },
  { id: 'cat-environment', name: 'Environmental Health', description: 'PM2.5, heat index, hydration, and safety messaging.' },
  { id: 'cat-buddy', name: 'Buddy Personality', description: 'Tone, companion behavior, and chatbot style rules.' },
  { id: 'cat-system', name: 'System Prompts', description: 'Internal prompts, safety policies, and response constraints.' },
];
