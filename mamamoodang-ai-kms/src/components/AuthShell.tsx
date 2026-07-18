import { Github, LockKeyhole } from 'lucide-react';
import { Button } from './ui/Button';
import { Card, CardContent } from './ui/Card';
import { Input, Label } from './ui/Field';

type AuthShellProps = {
  mode: 'preview' | 'supabase';
  loading?: boolean;
  error?: string;
  onEnter?: () => void;
  onGitHubSignIn?: () => void;
};

export function AuthShell({ mode, loading = false, error, onEnter, onGitHubSignIn }: AuthShellProps) {
  const isSupabase = mode === 'supabase';

  return (
    <main className="flex min-h-screen items-center justify-center bg-background px-4">
      <Card className="w-full max-w-md">
        <CardContent className="space-y-5 p-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/15 text-primary">
            <LockKeyhole size={22} />
          </div>
          <div>
            <h1 className="text-2xl font-bold">Mamamoodang AI Training Workspace</h1>
            <p className="mt-2 text-sm leading-6 text-muted-foreground">
              {isSupabase
                ? 'Sign in with an approved GitHub account to manage chatbot knowledge in Supabase.'
                : 'Internal conversational workspace for building medical chatbot knowledge. Preview mode stores data in this browser only.'}
            </p>
          </div>
          {!isSupabase && (
            <div className="space-y-3">
              <div className="space-y-1.5">
                <Label>Email</Label>
                <Input value="admin@mamamoodang.internal" readOnly />
              </div>
              <div className="space-y-1.5">
                <Label>Role</Label>
                <Input value="Admin preview mode" readOnly />
              </div>
            </div>
          )}
          {error && (
            <div className="rounded-xl border border-destructive/30 bg-destructive/10 px-4 py-3 text-sm font-semibold text-destructive">
              {error}
            </div>
          )}
          {isSupabase ? (
            <Button className="w-full" onClick={onGitHubSignIn} disabled={loading}>
              <Github size={16} />
              {loading ? 'Checking session...' : 'Continue with GitHub'}
            </Button>
          ) : (
            <Button className="w-full" onClick={onEnter}>
              Enter Training Workspace
            </Button>
          )}
        </CardContent>
      </Card>
    </main>
  );
}
