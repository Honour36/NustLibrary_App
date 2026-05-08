import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'nust_secret_key_2024';

// Helper to validate student ID
const isValidStudentId = (id: string) => {
  return id.toLowerCase().startsWith('n');
};

// Register
router.post('/register', async (req: Request, res: Response) => {
  const { email, password, full_name, student_id } = req.body;
  console.log(`[Auth] Custom Registration attempt: ${email}`);

  if (!email || !password || !full_name || !student_id) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  if (!isValidStudentId(student_id)) {
    return res.status(400).json({ error: 'Student ID must start with "n"' });
  }

  try {
    // 1. Check if user already exists in custom table
    const { data: existingUser } = await supabase
      .from('app_users')
      .select('id')
      .or(`email.eq.${email},student_id.eq.${student_id}`)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'Email or Student ID already registered' });
    }

    // 2. Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 3. Create user in custom table
    const { data, error } = await supabase
      .from('app_users')
      .insert([
        { 
          email: email.trim().toLowerCase(), 
          password: hashedPassword, 
          full_name: full_name.trim(), 
          student_id: student_id.trim().toLowerCase() 
        }
      ])
      .select()
      .single();

    if (error) {
      console.error('[Auth] Custom user creation failed:', error.message);
      return res.status(400).json({ error: error.message });
    }

    console.log(`[Auth] Custom user created: ${data.id}`);
    return res.status(201).json({ 
      user: { id: data.id, email: data.email, user_metadata: { full_name: data.full_name, student_id: data.student_id } },
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
  console.log(`[Auth] Custom Login attempt: ${email}`);

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // 1. Find user in custom table
    const { data: user, error } = await supabase
      .from('app_users')
      .select('*')
      .eq('email', email.trim().toLowerCase())
      .single();

    if (error || !user) {
      console.warn(`[Auth] Login failed: User not found (${email})`);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // 2. Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.warn(`[Auth] Login failed: Incorrect password for ${email}`);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // 3. Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    console.log(`[Auth] Custom Login successful: ${user.id}`);
    
    // Return format compatible with existing frontend AuthService
    return res.status(200).json({ 
      user: { 
        id: user.id, 
        email: user.email, 
        user_metadata: { 
          full_name: user.full_name, 
          student_id: user.student_id 
        } 
      }, 
      session: { 
        access_token: token, 
        expires_in: 604800 // 7 days in seconds
      } 
    });
  } catch (err) {
    console.error(`[Auth] Internal login error:`, err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Get User Profile (including faculty and program names)
router.get('/profile/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('*, faculties(name), programs(name)')
      .eq('id', id)
      .single();

    if (error || !profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    return res.json({
      faculty: profile.faculties?.name || 'Unknown Faculty',
      program: profile.programs?.name || 'Unknown Program',
      year: profile.academic_year || 'Unknown Year'
    });
  } catch (err) {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Forgot Password (Dummy for now, since we aren't sending emails)
router.post('/forgot-password', async (req: Request, res: Response) => {
  return res.status(501).json({ error: 'Forgot password is not supported in custom auth mode yet.' });
});

export default router;

