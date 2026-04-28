import { Router, Request, Response } from 'express';
import multer from 'multer';
import { supabase } from '../config/supabase';
import { v4 as uuidv4 } from 'uuid';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

const BUCKET_NAME = 'pdfs';

// Initialize buckets
router.get('/init', async (_req: Request, res: Response) => {
  const buckets = ['pdfs', 'user-icons'];
  const results = [];

  for (const bucket of buckets) {
    try {
      const { data, error } = await supabase.storage.createBucket(bucket, {
        public: true
      });
      
      if (error) {
        if (error.message.includes('already exists')) {
          results.push({ bucket, status: 'already exists' });
        } else {
          results.push({ bucket, status: 'error', error: error.message });
        }
      } else {
        results.push({ bucket, status: 'created', data });
      }
    } catch (err: any) {
      results.push({ bucket, status: 'exception', error: err.message });
    }
  }

  return res.json(results);
});

// Sync bucket files to database
router.get('/sync', async (_req: Request, res: Response) => {
  try {
    // 1. List all files in the bucket
    const { data: files, error: storageError } = await supabase.storage
      .from(BUCKET_NAME)
      .list('pdfs'); // Check the 'pdfs' folder inside the bucket

    if (storageError) {
      // Try root if 'pdfs' folder doesn't exist
      const { data: rootFiles, error: rootError } = await supabase.storage.from(BUCKET_NAME).list('');
      if (rootError) throw rootError;
      return syncFiles(rootFiles || [], '', res);
    }

    return syncFiles(files || [], 'pdfs/', res);
  } catch (error: any) {
    console.error('Sync Error:', error);
    return res.status(500).json({ error: 'Failed to sync storage with database', details: error.message });
  }
});

async function syncFiles(files: any[], prefix: string, res: Response) {
  try {
    // 2. Get existing PDF URLs from database
    const { data: existingPdfs } = await supabase.from('pdfs').select('file_url');
    const existingUrls = new Set((existingPdfs || []).map(p => p.file_url));
    
    // 3. Get a default category
    const { data: category } = await supabase.from('categories').select('id').limit(1).single();
    const defaultCategoryId = category?.id;

    const imported = [];
    for (const file of files) {
      if (file.name === '.emptyFolderPlaceholder') continue;
      
      const { data: urlData } = supabase.storage.from(BUCKET_NAME).getPublicUrl(`${prefix}${file.name}`);
      const url = urlData.publicUrl;

      if (!existingUrls.has(url)) {
        // Create a record for the orphaned file
        const title = file.name.split('-').slice(1).join('-').split('.').first() || file.name;
        
        const { data: newDoc, error: insertError } = await supabase.from('pdfs').insert({
          title: title.replace(/%20/g, ' '),
          file_url: url,
          category_id: defaultCategoryId,
          author: 'System Import',
          views: 0,
          downloads: 0
        }).select().single();

        if (!insertError) imported.push(newDoc);
      }
    }

    return res.json({ 
      message: 'Sync complete', 
      found: files.length, 
      imported_count: imported.length,
      imported 
    });
  } catch (error: any) {
    return res.status(500).json({ error: 'Sync failed during processing', details: error.message });
  }
}

// Upload a file to Supabase Storage
router.post('/upload', upload.single('file'), async (req: Request, res: Response) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const bucket = req.body.bucket || BUCKET_NAME;
  const folder = req.body.folder || 'pdfs';
  const fileName = `${folder}/${uuidv4()}-${req.file.originalname}`;

  try {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true
      });

    if (error) throw error;

    const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(fileName);

    return res.json({ 
      message: 'File uploaded successfully',
      url: urlData.publicUrl,
      key: fileName 
    });
  } catch (error: any) {
    console.error('Supabase Storage Upload Error:', error);
    return res.status(500).json({ error: 'Failed to upload file to storage', details: error.message });
  }
});

// List files in a bucket/folder
router.get('/files', async (req: Request, res: Response) => {
  const folder = (req.query.folder as string) || '';
  const bucket = (req.query.bucket as string) || BUCKET_NAME;

  try {
    const { data, error } = await supabase.storage.from(bucket).list(folder);
    if (error) throw error;

    const files = (data || []).map((item) => {
      const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(`${folder}/${item.name}`);
      return {
        key: item.name,
        size: item.metadata?.size,
        lastModified: item.updated_at,
        url: urlData.publicUrl
      };
    });

    return res.json(files);
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to fetch files from storage', details: error.message });
  }
});

export default router;
