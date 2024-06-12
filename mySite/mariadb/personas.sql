CREATE TABLE people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    email VARCHAR(100)
);

INSERT INTO people (name, age, email) VALUES
    ('John Doe', 25, 'john.doe@example.com'),
    ('Jane Smith', 30, 'jane.smith@example.com'),
    ('Mike Johnson', 35, 'mike.johnson@example.com');