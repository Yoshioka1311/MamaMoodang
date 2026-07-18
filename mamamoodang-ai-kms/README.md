# Mamamoodang AI Knowledge Training Workspace

Internal administration tool for training the knowledge base used by the Mamamoodang chatbot.

The workflow is conversation-first:

- Create a knowledge topic with only a title and category.
- Chat naturally with the medical knowledge assistant.
- Every admin message and AI response is saved automatically.
- The conversation history becomes the source knowledge document.
- Delete is the only destructive action and requires confirmation.

## Run locally

```bash
npm install
npm run dev
```

## Supabase

Apply `supabase/schema.sql` to a Supabase PostgreSQL project. The schema uses:

- `knowledge_categories`
- `knowledge_topics`
- `chat_messages`
- `admin_profiles`

When Supabase environment variables are present, the app stores topic conversations in Supabase. Without credentials, it falls back to seeded browser storage so the workspace can be tested locally.

## Environment

Copy `.env.example` to `.env.local` and add Supabase credentials when the backend is ready.
