// src/components/ImageGallery.js
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
                        src={`http://localhost:5000${image.imageUrl}`}
                        alt={image.title}
                        onClick={() => setSelectedImage(image)}
                    />
                ))}
            </div>
            {selectedImage && (
                <div className="image-info">
                    <h2>{selectedImage.title}</h2>
                    <p>{selectedImage.description}</p>
                    <img src={`http://localhost:5000${selectedImage.imageUrl}`} alt={selectedImage.title} />
                </div>
            )}
        </div>
    );
};

export default ImageGallery;
