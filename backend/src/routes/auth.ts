import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

// Register
router.post('/register', async (req: Request, res: Response) => {
  const { email, password, full_name, student_id } = req.body;
  console.log(`[Auth] Registration attempt: ${email}`);
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name, student_id } },
    });
    if (error) {
      console.error(`[Auth] Registration failed for ${email}:`, error.message);
      return res.status(400).json({ error: error.message });
    }

    // Try to auto-confirm if we have admin privileges (optional/best effort)
    try {
      if (data.user) {
        await supabase.auth.admin.updateUserById(data.user.id, { email_confirm: true });
        console.log(`[Auth] Auto-confirmed user: ${data.user.id}`);
      }
    } catch (adminErr: any) {
      console.log(`[Auth] Could not auto-confirm (expected if using anon key): ${adminErr.message}`);
    }

    console.log(`[Auth] User created: ${data.user?.id} (Confirmed: ${data.user?.email_confirmed_at != null})`);
    return res.status(201).json({ 
      user: data.user, 
      session: data.session,
      message: data.session ? 'Registration successful' : 'Registration successful, please confirm your email'
    });
  } catch (err) {
    console.error(`[Auth] Internal registration error:`, err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Login
router.post('/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;
  console.log(`[Auth] Login attempt: ${email}`);

  // Development Bypass for local testing/demo
  if (process.env.NODE_ENV !== 'production' && password === 'nust_bypass_2024') {
    console.log(`[Auth] Bypass login triggered for ${email}`);
    return res.status(200).json({ 
      user: { id: '00000000-0000-0000-0000-000000000000', email, user_metadata: { full_name: 'Dev User' } },
      session: { access_token: 'mock-session-token', expires_in: 3600 }
    });
  }

  try {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      console.warn(`[Auth] Login failed for ${email}:`, error.message);
      
      // Handle specific Supabase errors
      if (error.message.includes('Invalid login credentials')) {
        return res.status(401).json({ error: 'The email or password you entered is incorrect.' });
      }
      if (error.message.toLowerCase().includes('confirm')) {
        return res.status(401).json({ error: 'Email not confirmed. Please check your inbox for a verification link.' });
      }
      
      return res.status(401).json({ error: error.message });
    }
    console.log(`[Auth] Login successful: ${data.user?.id}`);
    return res.status(200).json({ user: data.user, session: data.session });
  } catch (err) {
    console.error(`[Auth] Internal login error:`, err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Logout
router.post('/logout', async (req: Request, res: Response) => {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) return res.status(400).json({ error: error.message });
    return res.status(200).json({ message: 'Logged out successfully' });
  } catch (err) {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
