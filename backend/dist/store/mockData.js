"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.downloads = exports.flags = exports.reviews = exports.uploads = void 0;
exports.uploads = [
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
exports.reviews = [
    {
        id: 'review-1',
        document_id: 'seed-doc',
        user_name: 'Student reviewer',
        rating: 4,
        comment: 'Clear summary and useful past questions.',
        created_at: new Date().toISOString(),
    },
];
exports.flags = [];
exports.downloads = [
    {
        id: 'download-1',
        user_id: 'seed-user',
        title: 'Offline sample document',
        status: 'available offline',
    },
];
