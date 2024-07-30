// src/components/ImageUpload.js
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
