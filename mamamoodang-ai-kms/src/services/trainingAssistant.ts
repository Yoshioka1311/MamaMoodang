import type { KnowledgeTopic, TopicChatMessage } from '../types/knowledge';

function recentContext(messages: TopicChatMessage[]) {
  return messages
    .slice(-8)
    .map((message) => `${message.role === 'user' ? 'Admin' : 'AI'}: ${message.message}`)
    .join('\n');
}

function topicFocus(topic: KnowledgeTopic) {
  return `${topic.title} (${topic.categoryName})`;
}

export function generateTrainingResponse(topic: KnowledgeTopic, messages: TopicChatMessage[], prompt: string) {
  const lower = prompt.toLowerCase();
  const context = recentContext(messages);
  const focus = topicFocus(topic);

  if (lower.includes('faq')) {
    return `## FAQ draft for ${focus}

**Q: What should Buddy explain first?**
Buddy should start with the safest, simplest explanation and avoid making the user feel blamed.

**Q: What should the chatbot avoid?**
Avoid diagnosis, absolute promises, and replacing advice from the user's doctor or diabetes care team.

**Q: How should this become chatbot knowledge?**
Store the final answer as short guidance, safety boundaries, escalation signs, and Buddy-style wording.`;
  }

  if (lower.includes('simplify') || lower.includes('patient')) {
    return `Here is a patient-friendly version for **${focus}**:

Buddy can say this gently and clearly:

"Let us keep this simple. Your body may respond differently day by day, so we will choose the safer option, watch how you feel, and use your readings or care-team plan as the guide."

Medical safety boundary: this should support education only and should not replace personalized clinical advice.`;
  }

  if (lower.includes('reference')) {
    return `## Reference plan for ${focus}

- Use official clinical or public-health guidance where possible.
- Separate confirmed guidance from app-specific Buddy tone.
- Add a safety note when the topic involves symptoms, medication, glucose readings, heat, air quality, or emotional distress.
- Mark any uncertain claim for medical review before chatbot release.`;
  }

  if (lower.includes('buddy')) {
    return `## Buddy response candidates for ${focus}

1. "I am here with you. Let us take this one small step at a time."
2. "That sounds important. We can keep it gentle, safe, and check what your body tells us."
3. "If anything feels worrying or unusual, your care team is the best place to confirm what is right for you."

Tone rules: warm, short, non-judgmental, medically cautious.`;
  }

  if (lower.includes('summarize') || lower.includes('summary')) {
    return `## Working summary for ${focus}

Based on this conversation so far:

${context || 'No detailed notes have been added yet.'}

Suggested knowledge structure:
- Core explanation
- What Buddy should say
- Safety boundaries
- When to contact a healthcare professional
- Keywords for retrieval`;
  }

  return `I will help build this knowledge topic: **${focus}**.

Here is a stronger training draft based on your message:

${prompt}

Recommended next step: ask me to **expand**, **simplify for patients**, **create FAQs**, **write Buddy responses**, **add safety boundaries**, or **convert this into chatbot knowledge**. Every message in this conversation is already saved as part of the knowledge base.`;
}
