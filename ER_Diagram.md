erDiagram
    MEMBERS ||--o{ LOANS : places
    MEMBERS ||--o{ RESERVATIONS : makes
    MEMBERS ||--o{ FINES : accrues

    BOOKS ||--o{ LOANS : borrowed_in
    BOOKS ||--o{ RESERVATIONS : reserved_in
    BOOKS ||--o{ BOOK_AUTHORS : has

    AUTHORS ||--o{ BOOK_AUTHORS : writes
    PUBLISHERS ||--o{ BOOKS : publishes

    LOANS ||--|| FINES : generates
