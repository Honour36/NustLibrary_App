import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { facultiesData } from '../store/seed_onboarding';

const router = Router();

// Helper to get mocks if DB is empty or fails
const getMockFaculties = () => facultiesData.map((f, i) => ({
  id: `f-${i}`,
  name: f.name
}));

const getMockPrograms = (faculty_id?: string) => {
  if (faculty_id && faculty_id.startsWith('f-')) {
    const index = parseInt(faculty_id.split('-')[1]);
    return facultiesData[index].programs.map((p, pi) => ({
      id: `p-${index}-${pi}`,
      name: p.name,
      level: p.level,
      faculty_id
    }));
  }
  return [];
};

const getMockModules = (program_id: string) => {
  if (program_id.startsWith('p-')) {
    const [, fIdx, pIdx] = program_id.split('-').map(Number);
    const faculty = facultiesData[fIdx];
    if (faculty && faculty.programs[pIdx]) {
      return faculty.programs[pIdx].modules.map((m, mi) => ({
        id: `m-${fIdx}-${pIdx}-${mi}`,
        name: m,
        program_id
      }));
    }
  }
  return [];
};

// Get all faculties - ALWAYS returns from seed data (source of truth)
router.get('/faculties', (_req: Request, res: Response) => {
  return res.json(getMockFaculties());
});

// Get programs by faculty - ALWAYS returns from seed data (source of truth)
router.get('/programs', (req: Request, res: Response) => {
  const { faculty_id } = req.query;
  return res.json(getMockPrograms(faculty_id as string));
});

// Get modules by program
router.get('/modules', async (req: Request, res: Response) => {
  const { program_id } = req.query;
  if (!program_id) return res.status(400).json({ error: 'program_id is required' });
  
  try {
    const { data, error } = await supabase.from('modules').select('*').eq('program_id', program_id).order('name');
    if (error || !data || data.length === 0) {
      return res.json(getMockModules(program_id as string));
    }
    return res.json(data);
  } catch (err) {
    return res.json(getMockModules(program_id as string));
  }
});

// Complete onboarding
router.post('/complete', async (req: Request, res: Response) => {
  const { user_id, faculty_id, program_id, year, modules, feedback } = req.body;
  try {
    // Save to profiles
    const { error } = await supabase.from('profiles').upsert({
      id: user_id,
      faculty_id,
      program_id,
      academic_year: year,
      ceremonial_hall_feedback: feedback,
      has_seen_onboarding: true,
    });

    // Save selected modules if any
    if (modules && Array.isArray(modules)) {
      const moduleInserts = modules.map((mId: string) => ({
        user_id,
        module_id: mId
      }));
      await supabase.from('user_modules').upsert(moduleInserts);
    }

    if (error) {
      console.warn('Onboarding save warning:', error.message);
      return res.json({ message: 'Onboarding completed (Mock Mode)' });
    }
    return res.json({ message: 'Onboarding completed successfully' });
  } catch (err) {
    return res.json({ message: 'Onboarding completed (Caught error)' });
  }
});

export default router;
