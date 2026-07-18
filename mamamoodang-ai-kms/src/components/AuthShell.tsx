import { LockKeyhole } from 'lucide-react';
import { Button } from './ui/Button';
import { Card, CardContent } from './ui/Card';
import { Input, Label } from './ui/Field';

export function AuthShell({ onEnter }: { onEnter: () => void }) {
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
              Internal conversational workspace for building medical chatbot knowledge. Supabase Auth can be connected from the repository layer.
            </p>
          </div>
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
          <Button className="w-full" onClick={onEnter}>
            Enter Training Workspace
          </Button>
        </CardContent>
      </Card>
    </main>
  );
}
