import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { supabase } from '@/lib/supabase';

export function AuthForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      if (isSignUp) {
        await supabase.auth.signUp({
          email,
          password,
        });
      } else {
        await supabase.auth.signInWithPassword({
          email,
          password,
        });
      }
    } catch (error) {
      console.error('Authentication error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>{isSignUp ? 'Create Account' : 'Welcome Back'}</CardTitle>
        <CardDescription>
          {isSignUp ? 'Create a new account to continue' : 'Sign in to your account to continue'}
        </CardDescription>
      </CardHeader>
      <form onSubmit={handleAuth}>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
        </CardContent>
        <CardFooter className="flex flex-col space-y-4">
          <Button className="w-full" type="submit" disabled={isLoading}>
            {isLoading ? 'Loading...' : isSignUp ? 'Sign Up' : 'Sign In'}
          </Button>
          <Button
            variant="ghost"
            className="w-full"
            type="button"
            onClick={() => setIsSignUp(!isSignUp)}
          >
            {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}