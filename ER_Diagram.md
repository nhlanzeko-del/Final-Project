erDiagram
    %% Member Relationships
    MEMBERS ||--o{ LOANS : places
    MEMBERS ||--o{ RESERVATIONS : makes
    MEMBERS ||--o{ FINES : accrues

    %% Book Relationships
    BOOKS ||--o{ LOANS : borrowed_in
    BOOKS ||--o{ RESERVATIONS : reserved_in
    BOOKS ||--o{ BOOK_AUTHORS : has

    %% Author and Publisher Relationships
    AUTHORS ||--o{ BOOK_AUTHORS : writes
    PUBLISHERS ||--o{ BOOKS : publishes

    %% Loan and Fine Relationship
    LOANS ||--|| FINES : generates
