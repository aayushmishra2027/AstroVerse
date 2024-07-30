// server.js
const express = require('express');
const multer = require('multer');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

mongoose.connect('mongodb://localhost/astronomy', { useNewUrlParser: true, useUnifiedTopology: true });

const imageSchema = new mongoose.Schema({
    title: String,
    description: String,
    imageUrl: String,
    date: { type: Date, default: Date.now }
});

const Image = mongoose.model('Image', imageSchema);

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage });

app.post('/upload', upload.single('image'), (req, res) => {
    const newImage = new Image({
        title: req.body.title,
        description: req.body.description,
        imageUrl: `/uploads/${req.file.filename}`
    });
    newImage.save().then(image => res.json(image)).catch(err => res.status(500).json(err));
});

app.get('/images', (req, res) => {
    Image.find().then(images => res.json(images)).catch(err => res.status(500).json(err));
});

app.listen(5000, () => {
    console.log('Server started on port 5000');
});
