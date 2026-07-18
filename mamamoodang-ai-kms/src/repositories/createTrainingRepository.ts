import type { SupabaseClient } from '@supabase/supabase-js';
import { SupabaseTrainingRepository, createSupabaseBrowserClient } from './supabaseTrainingRepository';
import { TopicRepository } from './topicRepository';
import type { TrainingRepository } from './trainingRepository';

export function createTrainingRepository(client?: SupabaseClient | null): TrainingRepository {
  const supabase = client ?? createSupabaseBrowserClient();
  return supabase ? new SupabaseTrainingRepository(supabase) : new TopicRepository();
}
