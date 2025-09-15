# Library Management System - ER Diagram Documentation

## 📋 Entity-Relationship Diagram Overview

```mermaid
erDiagram
    MEMBERS ||--o{ LOANS : "places"
    MEMBERS ||--o{ RESERVATIONS : "makes"
    MEMBERS ||--o{ FINES : "accrues"
    
    BOOKS ||--o{ LOANS : "is_borrowed_in"
    BOOKS ||--o{ RESERVATIONS : "is_reserved_in"
    BOOKS ||--o{ BOOK_AUTHORS : "has"
    
    AUTHORS ||--o{ BOOK_AUTHORS : "writes"
    PUBLISHERS ||--o{ BOOKS : "publishes"
    
    LOANS ||--|| FINES : "generates"
