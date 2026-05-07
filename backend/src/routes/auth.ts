import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

// Register
router.post('/register', async (req: Request, res: Response) => {
  const { email, password, full_name, student_id } = req.body;
  console.log(`[Auth] Registration attempt: ${email}`);
  
  try {
    // We use admin.createUser to bypass email confirmation requirements
    // This requires the SUPABASE_SERVICE_ROLE_KEY to be set in .env
    const { data, error } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name, student_id }
    });

    if (error) {
      console.error(`[Auth] Admin creation failed for ${email}:`, error.message);
      
      // If user already exists, we should try to update/confirm them instead of falling back to signUp
      if (error.message.includes('already registered') || error.message.includes('already exists')) {
        console.log(`[Auth] User ${email} already exists. Attempting to ensure they are confirmed...`);
        
        // Find the user to get their ID
        const { data: userList } = await supabase.auth.admin.listUsers();
        const existingUser = userList?.users.find(u => u.email === email);
        
        if (existingUser) {
          // Force confirm and update metadata just in case
          await supabase.auth.admin.updateUserById(existingUser.id, { 
            email_confirm: true,
            user_metadata: { full_name, student_id }
          });
          
          return res.status(201).json({ 
            user: existingUser, 
            message: 'User already registered. You can now log in.' 
          });
        }
      }

      // If it's a real failure (not "already exists"), try fallback ONLY if it's not a service role issue
      if (error.message.includes('not authorized') || error.message.includes('Invalid key')) {
        return res.status(401).json({ error: 'Server configuration error: Admin API unauthorized.' });
      }

      console.warn(`[Auth] Falling back to standard signUp for ${email}...`);
      const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { full_name, student_id } },
      });

      if (signUpError) {
        console.error(`[Auth] Fallback signUp failed:`, signUpError.message);
        return res.status(400).json({ error: signUpError.message });
      }

      // Auto-confirm if signup succeeded but needs confirmation
      if (signUpData.user) {
        await supabase.auth.admin.updateUserById(signUpData.user.id, { email_confirm: true });
      }

      return res.status(201).json({ 
        user: signUpData.user, 
        message: 'Registration successful' 
      });
    }

    console.log(`[Auth] User created via admin: ${data.user?.id}`);
    return res.status(201).json({ 
      user: data.user, 
      message: 'Registration successful' 
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
    let { data, error } = await supabase.auth.signInWithPassword({ email, password });
    
    // If login fails because of unconfirmed email, try to auto-confirm and retry
    if (error && error.message.toLowerCase().includes('confirm')) {
      console.log(`[Auth] Login blocked by confirmation for ${email}. Attempting auto-confirm...`);
      
      // We need to find the user ID to confirm them. Since signIn failed, we fetch them by email.
      const { data: userList, error: listError } = await supabase.auth.admin.listUsers();
      const user = userList?.users.find(u => u.email === email);
      
      if (user) {
        await supabase.auth.admin.updateUserById(user.id, { email_confirm: true });
        console.log(`[Auth] Auto-confirmed user ${user.id} during login retry`);
        
        // Retry login
        const retry = await supabase.auth.signInWithPassword({ email, password });
        data = retry.data;
        error = retry.error;
      }
    }

    if (error) {
      console.warn(`[Auth] Login failed for ${email}:`, error.message);
      
      // Handle specific Supabase errors
      if (error.message.includes('Invalid login credentials')) {
        return res.status(401).json({ error: 'The email or password you entered is incorrect.' });
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

// Forgot Password
router.post('/forgot-password', async (req: Request, res: Response) => {
  const { email } = req.body;
  console.log(`[Auth] Forgot password request for: ${email}`);

  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${process.env.FRONTEND_URL || 'http://localhost:3001'}/reset-password`,
    });

    if (error) {
      console.error(`[Auth] Forgot password failed for ${email}:`, error);
      return res.status(400).json({ error: error.message });
    }

    return res.status(200).json({ message: 'Password reset email sent' });
  } catch (err) {
    console.error(`[Auth] Internal forgot-password error:`, err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
