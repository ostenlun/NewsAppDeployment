CREATE DATABASE article_database;
\c article_database;

CREATE TABLE articles (
    article_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    title TEXT,
    language TEXT,
    published_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_user_id
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL
);



