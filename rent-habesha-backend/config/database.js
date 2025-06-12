import  mongoose from  'mongoose';

// Asynchronously connect to MongoDB using the URI from environment variables.
// Log success or, on failure, log the error and exit the process
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.DATABASE_URI);
    console.log('MongoDB Connected...');
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

export default connectDB;