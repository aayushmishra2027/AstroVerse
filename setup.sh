#!/bin/bash

# Replace these variables with your own values
REPO_NAME="astronomy-website"
GITHUB_USERNAME="your-username"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"

# Step 1: Create and clone the repository
curl -u $GITHUB_USERNAME https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\"}"
git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
cd $REPO_NAME

# Step 2: Create project structure
mkdir $FRONTEND_DIR $BACKEND_DIR

# Step 3: Initialize frontend
cd $FRONTEND_DIR
npx create-react-app .
npm install three @react-three/fiber @react-three/drei axios algoliasearch react-instantsearch-dom

# Step 4: Initialize backend
cd ../$BACKEND_DIR
npm init -y
npm install express multer mongoose cors

# Step 5: Create backend server.js file
cat <<EOF > server.js
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
        imageUrl: \`/uploads/\${req.file.filename}\`
    });
    newImage.save().then(image => res.json(image)).catch(err => res.status(500).json(err));
});

app.get('/images', (req, res) => {
    Image.find().then(images => res.json(images)).catch(err => res.status(500).json(err));
});

app.listen(5000, () => {
    console.log('Server started on port 5000');
});
EOF

# Step 6: Create frontend components
cd ../$FRONTEND_DIR/src/components

cat <<EOF > BlackHoleAnimation.js
import React from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';

const BlackHoleAnimation = () => {
    return (
        <Canvas>
            <ambientLight intensity={0.5} />
            <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
            <pointLight position={[-10, -10, -10]} />
            <OrbitControls />
        </Canvas>
    );
};

export default BlackHoleAnimation;
EOF

cat <<EOF > ImageUpload.js
import React, { useState } from 'react';
import axios from 'axios';

const ImageUpload = ({ onUpload }) => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [file, setFile] = useState(null);

    const handleSubmit = async (e) => {
        e.preventDefault();
        const formData = new FormData();
        formData.append('title', title);
        formData.append('description', description);
        formData.append('image', file);

        const res = await axios.post('http://localhost:5000/upload', formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });
        onUpload(res.data);
    };

    return (
        <form onSubmit={handleSubmit}>
            <input type="text" placeholder="Title" value={title} onChange={(e) => setTitle(e.target.value)} required />
            <textarea placeholder="Description" value={description} onChange={(e) => setDescription(e.target.value)} required />
            <input type="file" onChange={(e) => setFile(e.target.files[0])} required />
            <button type="submit">Upload</button>
        </form>
    );
};

export default ImageUpload;
EOF

cat <<EOF > ImageGallery.js
import React, { useEffect, useState } from 'react';
import axios from 'axios';

const ImageGallery = () => {
    const [images, setImages] = useState([]);
    const [selectedImage, setSelectedImage] = useState(null);

    useEffect(() => {
        const fetchImages = async () => {
            const res = await axios.get('http://localhost:5000/images');
            setImages(res.data);
        };
        fetchImages();
    }, []);

    return (
        <div>
            <div className="gallery">
                {images.map(image => (
                    <img
                        key={image._id}
                        src={`http://localhost:5000\${image.imageUrl}`}
                        alt={image.title}
                        onClick={() => setSelectedImage(image)}
                    />
                ))}
            </div>
            {selectedImage && (
                <div className="image-info">
                    <h2>{selectedImage.title}</h2>
                    <p>{selectedImage.description}</p>
                    <img src={`http://localhost:5000\${selectedImage.imageUrl}`} alt={selectedImage.title} />
                </div>
            )}
        </div>
    );
};

export default ImageGallery;
EOF

cat <<EOF > SearchBar.js
import React from 'react';
import algoliasearch from 'algoliasearch/lite';
import { InstantSearch, SearchBox, Hits } from 'react-instantsearch-dom';

const searchClient = algoliasearch('YourAppID', 'YourSearchOnlyAPIKey');

const SearchBar = ()
