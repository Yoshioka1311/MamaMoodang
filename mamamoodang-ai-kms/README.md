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

Training data is shared through Supabase only when all of these are true:

- `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are configured in the hosting environment.
- The user signs in with GitHub through Supabase Auth.
- The signed-in user's UUID exists in `public.admin_profiles`.

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

5. Open Authentication > Providers > GitHub and enable GitHub OAuth.
6. Add this local redirect URL in Supabase Auth settings:

```text
http://127.0.0.1:5173
```

7. Start the workspace:

```bash
npm run dev
```

8. Sign in with GitHub once, then add that user as an admin from SQL Editor.

Use the authenticated user's UUID from Authentication > Users:

```sql
insert into public.admin_profiles (user_id, role)
values ('PASTE_AUTH_USER_UUID_HERE', 'admin')
on conflict (user_id) do update set role = 'admin';
```

After the admin row exists, refresh the local site and the training topics will read and write through Supabase.

## Environment

Copy `.env.example` to `.env.local` and add Supabase credentials when the backend is ready.
