// src/App.js
import React, { useState } from 'react';
import BlackHoleAnimation from './components/BlackHoleAnimation';
import SearchBar from './components/SearchBar';
import ImageUpload from './components/ImageUpload';
import ImageGallery from './components/ImageGallery';
import './App.css';

function App() {
    const [images, setImages] = useState([]);

    const handleUpload = (newImage) => {
        setImages([...images, newImage]);
    };

    return (
        <div className="App">
            <header className="App-header">
                <h1>Astronomy Explorer</h1>
                <SearchBar />
            </header>
            <main>
                <BlackHoleAnimation />
                <ImageUpload onUpload={handleUpload} />
                <ImageGallery images={images} />
            </main>
        </div>
    );
}

export default App;
