const mongoose = require("mongoose");
const path = require("path");

const connectDB = async () => {
  try {
    const caFile = path.join(process.cwd(), "global-bundle.pem");

    const conn = await mongoose.connect(process.env.MONGO_URI, {
      tls: true,
      tlsCAFile: caFile,
      retryWrites: false,
    });

    console.log(`DB Connected: ${conn.connection.host}`);
  } catch (err) {
    console.error("DB connection error:", err);
    process.exit(1);
  }
};

module.exports = connectDB;
