const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

console.log("S3 ENV CHECK:", !!process.env.AWS_ACCESS_KEY_ID, !!process.env.AWS_SECRET_ACCESS_KEY, process.env.AWS_REGION, process.env.S3_BUCKET);
// Create S3 client using your IAM keys from .env
const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

/**
 * POST /api/s3/upload-url
 * Body: { fileName: "photo.jpg", contentType: "image/jpeg" }
 * Returns: { uploadUrl, key }
 */
exports.getUploadUrl = async (req, res) => {
  try {
    const { fileName, contentType } = req.body;

    if (!fileName || !contentType) {
      return res.status(400).json({
        message: "fileName and contentType are required",
      });
    }

    // Store everything under /uploads (we can change per feature later)
    const key = `uploads/${Date.now()}-${fileName}`;

    const command = new PutObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Key: key,
      ContentType: contentType,
    });

    // URL valid for 60 seconds
    const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 900 });

    return res.json({ uploadUrl, key });
  } catch (err) {
    console.error("S3 getUploadUrl error:", err);
    return res.status(500).json({ message: "Failed to create upload URL" });
  }
};