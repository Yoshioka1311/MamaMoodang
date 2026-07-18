import { SupabaseTrainingRepository, createSupabaseBrowserClient } from './supabaseTrainingRepository';
import { TopicRepository } from './topicRepository';
import type { TrainingRepository } from './trainingRepository';

export function createTrainingRepository(): TrainingRepository {
  const supabase = createSupabaseBrowserClient();
  return supabase ? new SupabaseTrainingRepository(supabase) : new TopicRepository();
}
