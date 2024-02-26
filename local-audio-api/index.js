const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const tunnelmole = require("tunnelmole/cjs");

const app = express();
const upload = multer({
  dest: "uploads/",
  limits: {
    fileSize: 5000 * 1024 * 1024,
  },
});

app.post("/upload/:id", upload.single("audioFile"), (req, res) => {
  const id = req.params.id;
  const file = req.file;

  if (!file) {
    res.status(400).send("No file uploaded");
    return;
  }

  const uploadDir = path.join(__dirname, "uploads", id);
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
  }

  const filePath = path.join(uploadDir, file.originalname);
  fs.renameSync(file.path, filePath);

  res.status(200).send("File uploaded successfully");
  console.log(`File uploaded successfully - ${filePath}`);
});

app.get("/files/:id", (req, res) => {
  const id = req.params.id;
  const uploadDir = path.join(__dirname, "uploads", id);

  if (!fs.existsSync(uploadDir)) {
    res.status(404).send("ID not found");
    return;
  }

  fs.readdir(uploadDir, (err, files) => {
    if (err) {
      res.status(500).send("Error reading directory");
      return;
    }
    res.status(200).json({ files });
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
