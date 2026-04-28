import { Router, Request, Response } from 'express';
import { flags } from '../store/mockData';

const router = Router();

router.post('/', async (req: Request, res: Response) => {
  const flag = {
    id: `flag-${Date.now()}`,
    document_id: req.body.document_id ?? '',
    reason: req.body.reason ?? '',
    created_at: new Date().toISOString(),
  };
  flags.unshift(flag);
  return res.status(201).json(flag);
});

export default router;
