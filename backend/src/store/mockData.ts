type UploadItem = {
  id: string;
  title: string;
  author: string;
  category_name: string;
  description: string;
  file_url: string;
  user_id: string;
  user_name: string;
  status: string;
  created_at: string;
};

type ReviewItem = {
  id: string;
  document_id: string;
  user_name: string;
  rating: number;
  comment: string;
  created_at: string;
};

type FlagItem = {
  id: string;
  document_id: string;
  reason: string;
  created_at: string;
};

type DownloadItem = {
  id: string;
  user_id: string;
  title: string;
  status: string;
};

export const uploads: UploadItem[] = [
  {
    id: 'upload-1',
    title: 'Signals and Systems Revision Pack',
    author: 'E. Moyo',
    category_name: 'Electrical Engineering',
    description: 'Compiled revision material and worked examples.',
    file_url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    user_id: 'seed-user',
    user_name: 'Library Team',
    status: 'pending',
    created_at: new Date().toISOString(),
  },
];

export const reviews: ReviewItem[] = [
  {
    id: 'review-1',
    document_id: 'seed-doc',
    user_name: 'Student reviewer',
    rating: 4,
    comment: 'Clear summary and useful past questions.',
    created_at: new Date().toISOString(),
  },
];

export const flags: FlagItem[] = [];

export const downloads: DownloadItem[] = [
  {
    id: 'download-1',
    user_id: 'seed-user',
    title: 'Offline sample document',
    status: 'available offline',
  },
];
