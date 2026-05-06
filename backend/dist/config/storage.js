"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BUCKET_NAME = exports.s3Client = void 0;
const client_s3_1 = require("@aws-sdk/client-s3");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const endpoint = process.env.S3_ENDPOINT || "https://ibycqyrnpkhsljzifiza.storage.supabase.co/storage/v1/s3";
const region = process.env.S3_REGION || "eu-west-1";
// Note: Access Key and Secret Key are required for S3. 
// For Supabase, these are found in Settings > Storage > S3 Access Keys
exports.s3Client = new client_s3_1.S3Client({
    endpoint: endpoint,
    region: region,
    credentials: {
        accessKeyId: process.env.S3_ACCESS_KEY || "",
        secretAccessKey: process.env.S3_SECRET_KEY || "",
    },
    forcePathStyle: true, // Required for Supabase S3
});
exports.BUCKET_NAME = "pdfs"; // Default bucket name
