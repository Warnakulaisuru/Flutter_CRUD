import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch(err => console.log(err));

// Schema + Model
const noteSchema = new mongoose.Schema({
  title: String,
  content: String,
});

const Note = mongoose.model("Note", noteSchema);

// CRUD Routes
// Get all notes
app.get("/api/notes", async (req, res) => {
  const notes = await Note.find();
  res.json(notes);
});

// Add a new note
app.post("/api/notes", async (req, res) => {
  const note = await Note.create(req.body);
  res.json(note);
});

// Delete a note
app.delete("/api/notes/:id", async (req, res) => {
  await Note.findByIdAndDelete(req.params.id);
  res.json({ message: "Deleted" });
});

app.listen(process.env.PORT, () => console.log(`🚀 Server on ${process.env.PORT}`));
