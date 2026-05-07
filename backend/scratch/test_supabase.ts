import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

async function test() {
  const { data, error } = await supabase.auth.admin.listUsers();
  if (error) {
    console.error('Admin API failed:', error);
  } else {
    console.log('Admin API works! Found users:', data.users.length);
  }
}

test();
