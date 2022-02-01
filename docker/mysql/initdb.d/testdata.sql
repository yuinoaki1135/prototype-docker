INSERT INTO users(mail, gender, password, birthdate, create_user_id, create_timestamp)
VALUES
 ('test@gmail.com', 1, "cb199bcd91c11f626d46d87fc75bfe974f9c4fc4accd240ecc43040fbfcd3c9a0bf7106d0c913799", "1991/01/01", 0, current_timestamp);

INSERT INTO users_history(user_id, mail, gender, password, birthdate, note, create_user_id, create_timestamp)
VALUES
 (1, 'test@gmail.com', 1, "cb199bcd91c11f626d46d87fc75bfe974f9c4fc4accd240ecc43040fbfcd3c9a0bf7106d0c913799", "1991/01/01", "initial data", 0, current_timestamp);


 