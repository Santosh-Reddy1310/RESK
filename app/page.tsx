import { createServerComponentClient } from '@supabase/auth-helpers-nextjs';
import { cookies } from 'next/headers';
import { Assistant } from './assistant';
import { AuthForm } from '@/components/auth/auth-form';

export default async function Home() {
  const supabase = createServerComponentClient({ cookies });
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gray-50">
        <AuthForm />
      </div>
    );
  }

  return <Assistant />;
}