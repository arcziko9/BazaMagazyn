# Stworzenie bazy danych
CREATE DATABASE Warehouse;


# Stworzenie tabeli Discount
CREATE TABLE Discount (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	Value DECIMAL(8,2) NOT NULL DEFAULT 0.00,
	PRIMARY KEY(ID)
	);
	
	
# Stworzenie tabeli Address
CREATE TABLE Address (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	City VARCHAR(255) NOT NULL,
	Street VARCHAR(255) NOT NULL,
	Building_Number VARCHAR(10),
	Postal_Code CHAR(6),
	PRIMARY KEY(ID)
);


# Stworzenie tabeli Building
CREATE TABLE Building (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	Address_ID INT UNSIGNED NOT NULL,
	Name VARCHAR(255) NOT NULL,
	PRIMARY KEY(ID),
	FOREIGN KEY(Address_ID) REFERENCES Address(ID)
	);


# Stworzenie tabeli Tax
CREATE TABLE Tax (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	Value DECIMAL(8,2) NOT NULL DEFAULT 0.00,
	Description VARCHAR(255) NOT NULL,
	PRIMARY KEY(ID)
	);
	
	
# Stworzenie tabeli Product
CREATE TABLE Product (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	Name VARCHAR(255) NOT NULL UNIQUE,
	Tax_ID INT UNSIGNED NOT NULL,
	Price_Netto DECIMAL(8,2) NOT NULL,
	Avability INT UNSIGNED NOT NULL,
	Building_ID INT UNSIGNED NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY(Tax_ID) REFERENCES Tax(ID),
	FOREIGN KEY (Building_ID) REFERENCES Building(ID)
	);
	
	
# Stworzenie tabeli Employee
CREATE TABLE Employee (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	First_Name VARCHAR(255) NOT NULL,
	Last_Name VARCHAR(255) NOT NULL,
	Salary DECIMAL(8,2) NOT NULL,
	Hire_Date DATE NOT NULL,
	Birth_Date DATE NOT NULL,
	Building_ID INT UNSIGNED NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (Building_ID) REFERENCES Building(ID)
	);
	
	
# Stworzenie tabeli Customer
CREATE TABLE Customer (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	First_Name VARCHAR(255) NOT NULL,
	Last_Name VARCHAR(255) NOT NULL,
	Company_Name VARCHAR(255),
	Phone_Number VARCHAR(12) NOT NULL,
	Email VARCHAR(150) NOT NULL,
	Discount_ID INT UNSIGNED NOT NULL,
	Address_ID INT UNSIGNED NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (Discount_ID) REFERENCES Discount(ID),
	FOREIGN KEY (Address_ID) REFERENCES Address(ID)
	);
	
	
# Stworzenie tabeli Ordeer
CREATE TABLE Ordeer (
	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
	Employee_ID INT UNSIGNED NOT NULL,
	Customer_ID INT UNSIGNED NOT NULL,
	Status ENUM("Zamownienie zlozone", "Zamownienie potwierdzone",
				"Zamowienie przyjete do realizacji",
				"Zamowienie wyslane","Zamowienie anulowane")
				NOT NULL DEFAULT "Zamownienie zlozone",
	Order_Date DATE NOT NULL,
	Comment VARCHAR(255),
	PRIMARY KEY(ID),
	FOREIGN KEY (Employee_ID) REFERENCES Employee(ID),
	FOREIGN KEY (Customer_ID) REFERENCES Customer(ID)
	);
	
	
# Stworzenie tabeli Order_Detail
CREATE TABLE Order_Detail (
	Order_ID INT UNSIGNED NOT NULL,
	Product_ID INT UNSIGNED NOT NULL,
	Amount INT NOT NULL,
	FOREIGN KEY (Order_ID) REFERENCES Ordeer(ID),
	FOREIGN KEY (Product_ID) REFERENCES Product(ID)
	);


# Stworzenie widoku Produkty
CREATE VIEW Produkty AS
    SELECT
    S.ID AS "ID Produktu",
    S.Name AS "Nazwa Produktu",
    S.Price_Netto "Cena Netto",
    (S.Price_Netto * T.Value + S.Price_Netto) AS "Cena Brutto",
    S.Avability AS "Ilosc sztuk",
    B.Name AS "Nazwa budynku",
    Concat(A.Postal_Code, " ", A.City, " ", A.Street, " ", A.Building_Number) AS "Adres"
    FROM Product S
    JOIN Tax T
    ON  S.Tax_ID = T.ID
    JOIN Building B
    ON S.Building_ID = B.ID
    JOIN Address A
    ON B.Address_ID = A.ID;
	
	
# Stworzenie widoku Customer_View
CREATE VIEW Customer_View AS
    SELECT CU.ID, CU.First_Name, CU.Last_Name, 
    CU.Company_Name, CU.Phone_Number, CU.Email, AD.Postal_Code, AD.City, 
	AD.Street, AD.Building_Number , D.Value
    FROM Customer CU 
   JOIN Address AD ON CU.Address_ID = AD.ID
   JOIN Discount D ON CU.Discount_ID = D.ID;
   
   
# Stworzenie widoku Faktura		
CREATE VIEW Faktura AS
SELECT OD.Order_ID AS "Numer Zamowienia",
CONCAT(CONCAT(C.First_Name,' '), C.Last_Name) AS "Imie i nazwisko zamawiajacego",
C.COMPANY_NAME AS "Firma",
Concat(A.Postal_Code, " ", A.City, " ", A.Street, " ", A.Building_Number) AS "Adres zamawiajacego", 
O.Order_Date AS "Data zamowienia",
CONCAT(CONCAT(E.First_Name,' '), E.Last_Name) AS "Zamowienie Przyjal/ela",
P.Name AS "Nazwa Produktu",
OD.Amount AS "Ilosc produktu",
P.Price_Netto AS "Cena za sztuke",
(OD.Amount * P.Price_Netto) AS "Cena netto zamowienia",
(Amount * (P.Price_Netto * T.Value + P.Price_Netto)) AS "Cena brutto zamowienia",
T.Value AS "Podatek",
O.Comment AS "Komentarze do zamowienia"
FROM Order_Detail OD
JOIN Ordeer O
ON OD.Order_ID = O.ID
JOIN Customer C
ON O.Customer_ID = C.ID
JOIN Address A
ON C.Address_ID = A.ID
JOIN Employee E
ON O.Employee_ID = E.ID
JOIN Product P
ON OD.Product_ID = P.ID
JOIN Tax T
ON P.Tax_ID = T.ID
ORDER BY OD.ORDER_ID ASC;


# Uzupełnienie tabel danymi
# Adresy
INSERT INTO Address (ID, City, Street, Building_Number, Postal_Code)
VALUES
('1', 'Wroclaw', 'Krasickiego', '31', '50-001'),
('2', 'Wroclaw', 'Wyspianskiego', '9', '50-005'),
('3','Wroclaw', 'Ruska', '15', '50-011'),
('4','Lodz', 'Czysta', '8', '90-003'),
('5','Lodz', 'Piotrkowska', '24', '90-101'),
('6','Skoczow', 'Malinowska', '44', '43-430'),
('7','Gliwice', 'Czajki', '16', '44-100'),
('8','Gliwice', 'Akademicka', '316', '44-100'),
('9','Bielsko-Biala', 'Sportowa', '343', '43-512'),
('10', 'Warszawa', 'Smocza', '51a', '11-111');

# Budynki
INSERT INTO Building (ID, Address_ID, Name)
VALUES
('1','3','M1'),
('2','2','M2'),
('3','1','M3'),
('4','5','M4'),
('5','4','M5');

# Zniżki
INSERT INTO Discount(ID, Value)
VALUES 
('1', 0.1),
('2', 0.2),
('3', 0.3),
('4', 0.5),
('5', 0.8);

# Rodzaje Podatków
INSERT INTO Tax(ID, Value, Description)
VALUES
('1', 0, 'Nieopodatkowane'),
('2', 0.23, 'Podatek podstawowy'),
('3', 0.08, 'Podatek obnizony1'),
('4', 0.05, 'Podatek obnizony2');

# Produkty
INSERT INTO Product(ID, Name, Price_Netto, Tax_ID, Avability, Building_ID)
VALUES
('1','CHLEB PSZENNY DOMOWY',2.5, 2,1000, 1),
('2','CHLEB RAZOWY BEDNAREK',3, 2,2445, 2),
('3','DELMA',5, 2,4545, 3),
('4','LAYS',2.8, 2,11234, 2),
('5','SZYNKA',13, 2,1929, 1),
('6','KARKOWKA DOMOWA',12, 3,23256, 2),
('7','SZYNKA ZBOJECKA',10, 2,3456, 3),
('8','KIELBASA PODWAWELSKA',15, 2,3452, 1),
('9','ZELKI HARIBO',3, 2,3425, 2),
('10','SOK TYMBARK',2, 3,75432, 1);

# Pracownicy
INSERT INTO Employee(ID, First_Name, Last_Name, Salary, Birth_Date, Hire_Date, Building_ID)
VALUES
('1','Anna','Krawczyk',2500,'1977-11-11','2017-10-23',1),
('2','Marta','Glowacka',2400,'1987-11-06','2011-05-06',1),
('3','Kasia','Iwanowa',5000,'1999-10-23','2014-07-12',2),
('4','Julia','Basara',3000,'1945-06-07','2012-10-21',3),
('5','Agnieszka','Polanska',6000,'1968-05-23','2017-06-07',4),
('6','Marcin','Kubelek',2500,'1975-07-07','2011-10-12',5),
('7','Adrian','Prosty',1500,'2001-10-05','2014-06-07',3),
('8','Kuba','Piekarczyk',4000,'1960-10-07','2015-06-03',2),
('9','Kamil','Bednarek',10000,'1987-06-05','2015-04-06',1),
('10','Kazimierz','Wielki',20000,'1999-06-15','2013-05-02',5),
('11','Marek','Kierujacy',3000,'1990-10-12','2014-02-05',5);

# Klienci
INSERT INTO Customer(ID, First_Name, Last_Name, Company_Name, Phone_Number, Email, Discount_ID, Address_ID)
VALUES
('1','Alicja','Kolowska','zabka','324234543','alicja@gmail.com','1','6'),
('2','Adrianna','Rzechowicz','fresh','458733542','adrianna@gmail.com','1','6'),
('3','Beata','Niedbalec','tesco','643734572','beata@gmail.com','1','7'),
('4','Felicja','Bielawa','lidl','346523461','felicja@gmail.com','2','8'),
('5','Wanda','Stachlewski','kaufland','237345262','wanda@gmail.com','1','7'),
('6','Abraham','Basara','aldi','334627345','abraham@gmail.com','2','9'),
('7','Fabian','Fabecki','delikatesy','135634257','fabian@gmail.com','1','6'),

INSERT INTO Customer(ID, First_Name, Last_Name, Phone_Number, Email, Discount_ID, Address_ID)
VALUES
('8','Ignacy','Waberzak', '734252314','ignacy@gmail.com','2','10'),
('9','Wladyslaw','Wabicz', '194239458','wladyslaw@gmail.com','1','6'),
('10','Zbigniew','Sabczynski', '997112998','zbigniew@gmail.com','1','8');

# Zamowienia
INSERT INTO Ordeer(ID, Employee_ID, Customer_ID, Status, Order_Date, Comment)
VALUES
('1','1','1','Zamownienie zlozone','2018-05-05','DOKLADNIEJ ZAPAKOWAC'),
('2','2','1','Zamownienie zlozone','2018-05-08','DOKLADNIEJ ZAPAKOWAC'),
('3','3','1','Zamowienie przyjete do realizacji','2018-03-09','UWAGA TOWAR MIEKKI'),
('4','4','2','Zamowienie przyjete do realizacji','2018-02-12','UWAGA TOWAR MIEKKI'),
('5','5','2','Zamowienie przyjete do realizacji','2018-02-13','UZYWAC REKAWICZEK'),
('6','6','2','Zamowienie wyslane','2018-03-14','UZYWAC REKAWICZEK'),
('7','7','3','Zamowienie wyslane','2018-03-15','PAKOWAC PO 200'),
('8','8','3','Zamowienie wyslane','2018-04-16','PAKOWAC PO 15'),
('9','9','4','"Zamowienie anulowane"','2018-02-16','PAKOWAC PO 250');

# Szczegóły zamówienia, czyli produkt z ilością


INSERT INTO Order_Detail(Order_ID, Product_ID, Amount)
VALUES
(1,1,2500),
(1,2,3000),
(1,3,1500),
(1,4,200),
(2,5,600),
(2,6,700),
(2,7,400),
(2,8,500),
(2,9,800),
(3,10,1000),
(4,1,100),
(5,2,250),
(6,3,340),
(7,4,380),
(8,5,520),
(9,5,420);





