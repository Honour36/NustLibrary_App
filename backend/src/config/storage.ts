import { S3Client } from "@aws-sdk/client-s3";
import dotenv from "dotenv";

dotenv.config();

const endpoint = process.env.S3_ENDPOINT || "https://ibycqyrnpkhsljzifiza.storage.supabase.co/storage/v1/s3";
const region = process.env.S3_REGION || "eu-west-1";

// Note: Access Key and Secret Key are required for S3. 
// For Supabase, these are found in Settings > Storage > S3 Access Keys
export const s3Client = new S3Client({
  endpoint: endpoint,
  region: region,
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY || "",
    secretAccessKey: process.env.S3_SECRET_KEY || "",
  },
  forcePathStyle: true, // Required for Supabase S3
});

export const BUCKET_NAME = "pdfs"; // Default bucket name
