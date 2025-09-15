-- Library Management System Database
-- Created for Assignment Submission

-- Create database
CREATE DATABASE IF NOT EXISTS LibraryManagementSystem;
USE LibraryManagementSystem;

-- Table 1: Members (Library Members)
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    membership_date DATE NOT NULL,
    status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: Authors (Book Authors)
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nationality VARCHAR(50),
    birth_year INT,
    biography TEXT,
    CONSTRAINT chk_birth_year CHECK (birth_year BETWEEN 1500 AND YEAR(CURDATE()))
);

-- Table 3: Publishers (Book Publishers)
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15)
);

-- Table 4: Books (Main Books Table)
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    publication_year INT,
    genre VARCHAR(50) NOT NULL,
    edition INT DEFAULT 1,
    publisher_id INT,
    total_copies INT DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INT DEFAULT 1 CHECK (available_copies >= 0 AND available_copies <= total_copies),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_publication_year CHECK (publication_year BETWEEN 1450 AND YEAR(CURDATE())),
    CONSTRAINT chk_edition CHECK (edition >= 1)
);

-- Table 5: Book_Authors (Many-to-Many Relationship)
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Table 6: Loans (Book Lending Transactions)
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    fine_amount DECIMAL(10,2) DEFAULT 0.00 CHECK (fine_amount >= 0),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Table 7: Reservations (Book Reservations)
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    priority INT DEFAULT 1,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CONSTRAINT unique_active_reservation UNIQUE (book_id, member_id, status)
);

-- Table 8: Fines (Fine Records)
CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    issue_date DATE NOT NULL,
    paid_date DATE NULL,
    status ENUM('Unpaid', 'Paid', 'Waived') DEFAULT 'Unpaid',
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_paid_date CHECK (paid_date IS NULL OR paid_date >= issue_date)
);

-- Insert sample data
INSERT INTO Publishers (name, address, contact_email, contact_phone) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', 'info@penguinrandomhouse.com', '+1-212-782-9000'),
('HarperCollins', '195 Broadway, New York, NY', 'contact@harpercollins.com', '+1-212-207-7000'),
('Macmillan', '120 Broadway, New York, NY', 'support@macmillan.com', '+1-646-307-5151');

INSERT INTO Authors (first_name, last_name, nationality, birth_year) VALUES
('George', 'Orwell', 'British', 1903),
('J.K.', 'Rowling', 'British', 1965),
('Stephen', 'King', 'American', 1947),
('Jane', 'Austen', 'British', 1775);

INSERT INTO Books (title, isbn, publication_year, genre, edition, publisher_id, total_copies, available_copies) VALUES
('1984', '9780451524935', 1949, 'Dystopian', 1, 1, 5, 5),
('Animal Farm', '9780451526342', 1945, 'Political Satire', 1, 1, 3, 3),
('Harry Potter and the Philosopher''s Stone', '9780747532743', 1997, 'Fantasy', 1, 2, 8, 8),
('The Shining', '9780307743657', 1977, 'Horror', 1, 3, 4, 4),
('Pride and Prejudice', '9780141439518', 1813, 'Romance', 1, 1, 6, 6);

INSERT INTO Book_Authors (book_id, author_id) VALUES
(1, 1), (2, 1), (3, 2), (4, 3), (5, 4);

INSERT INTO Members (first_name, last_name, email, phone, membership_date) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101', '2024-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', '2024-02-20'),
('Bob', 'Johnson', 'bob.johnson@email.com', '555-0103', '2024-03-10');

-- Create indexes for better performance
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_genre ON Books(genre);
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_loans_dates ON Loans(loan_date, due_date, return_date);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_fines_status ON Fines(status);

-- Create a view for currently available books
CREATE VIEW AvailableBooks AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') as authors,
    b.genre,
    b.available_copies
FROM Books b
LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id
LEFT JOIN Authors a ON ba.author_id = a.author_id
WHERE b.available_copies > 0
GROUP BY b.book_id, b.title, b.isbn, b.genre, b.available_copies;

-- Create a view for currently active loans
CREATE VIEW ActiveLoans AS
SELECT 
    l.loan_id,
    m.first_name,
    m.last_name,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Active';

-- Create stored procedure for borrowing a book
DELIMITER //
CREATE PROCEDURE BorrowBook(IN p_book_id INT, IN p_member_id INT)
BEGIN
    DECLARE available_count INT;
    
    SELECT available_copies INTO available_count 
    FROM Books WHERE book_id = p_book_id;
    
    IF available_count > 0 THEN
        INSERT INTO Loans (book_id, member_id, loan_date, due_date)
        VALUES (p_book_id, p_member_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
        
        UPDATE Books 
        SET available_copies = available_copies - 1 
        WHERE book_id = p_book_id;
        
        SELECT 'SUCCESS' as status, 'Book borrowed successfully' as message;
    ELSE
        SELECT 'ERROR' as status, 'No copies available' as message;
    END IF;
END //
DELIMITER ;

-- Create trigger to update book availability after return
DELIMITER //
CREATE TRIGGER AfterBookReturn
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE Books 
        SET available_copies = available_copies + 1 
        WHERE book_id = NEW.book_id;
    END IF;
END //
DELIMITER ;

-- Display database structure information
SELECT 'Database and tables created successfully!' as Status;
SELECT COUNT(*) as 'Tables Created' FROM information_schema.tables 
WHERE table_schema = 'LibraryManagementSystem';
