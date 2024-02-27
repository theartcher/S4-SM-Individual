const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const ffmpeg = require("fluent-ffmpeg");
const localtunnel = require("localtunnel");

ffmpeg.setFfmpegPath("C:\\ffmpeg-2024-02-26-git-a3ca4beeaa-full_build\\bin\\ffmpeg.exe");

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
    return res.status(400).send("No file uploaded");
  }

  const uploadDir = path.join(__dirname, "uploads", id);
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
  }

  const filePath = path.join(uploadDir, file.originalname);
  fs.renameSync(file.path, filePath);

  console.log(`File uploaded successfully - ${filePath}`);
  return res.status(200).send("File uploaded successfully");
});

app.get("/files/:id", async (req, res) => {
  const id = req.params.id;
  const uploadDir = path.join(__dirname, "uploads", id);

  if (!fs.existsSync(uploadDir)) {
    return res.status(404).send("ID not found.");
  }

  try {
    const files = await fs.promises.readdir(uploadDir);
    const m4aFiles = files.filter((file) => file.endsWith(".m4a"));

    if (m4aFiles.length === 0) {
      return res.status(404).send("No audio files found.");
    }

    const outputFilePath = path.join(uploadDir, "output.m4a");

    if (fs.existsSync(outputFilePath)) {
      await fs.promises.unlink(outputFilePath);
    }

    const ffmpegCommand = ffmpeg();

    m4aFiles.forEach((file) => {
      if (file !== "output.m4a") {
        ffmpegCommand.input(path.join(uploadDir, file));
      }
    });

    await new Promise((resolve) => {
      ffmpegCommand
        .on("end", () => {
          resolve();
        })
        .mergeToFile(outputFilePath);
    });

    return res.status(200).download(outputFilePath, "output.m4a");
  } catch (error) {
    return res.status(500).send(`Internal server error - ${error}`);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

(async () => {
  const tunnel = await localtunnel({ port: 3000 });
  console.info("Tunnel available @ - ", tunnel.url);

  tunnel.on("close", () => {
    console.warn("Closed tunnel.");
  });
})();
