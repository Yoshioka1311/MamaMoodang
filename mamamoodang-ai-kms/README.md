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

## Hosting and data storage

When deployed on Vercel, the training website stays available without keeping a local computer on. Vercel serves the React app, and Supabase stores categories, topics, and chat messages.

Training data is shared through Supabase when `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are configured in the hosting environment. The workspace runs in public training mode, so anyone with the website link can create training topics and add messages.

Public training mode intentionally does not require GitHub login. Delete is hidden in the UI and the public Supabase policy does not allow deleting topics or messages.

Thai and English training content are both supported. Supabase `text` columns store Unicode content, and the assistant draft generator replies in Thai when the admin prompt or recent conversation uses Thai.

## Supabase setup checklist

1. Create a Supabase project.
2. Open SQL Editor and run the full `supabase/schema.sql` file.
3. Open Project Settings > API and copy the Project URL plus anon public key.
4. Copy `.env.example` to `.env.local` and fill in:

```bash
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

5. Start the workspace:

```bash
npm run dev
```

GitHub OAuth can remain enabled in Supabase for future admin-only features, but this public training workspace does not use it.

## Environment

Copy `.env.example` to `.env.local` and add Supabase credentials when the backend is ready.
