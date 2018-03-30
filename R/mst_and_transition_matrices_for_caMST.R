##### 18 item matrices #####
# 1-2-2 18 item
camst_matrix_1_2_2_18_item_1_6 <- rbind(matrix(nrow = 3, ncol = 5, data = rep(c(1,0,0,0,0),times=3), byrow=TRUE), matrix(nrow = 30, ncol = 5, data = c(rep(c(0,1,0,0,0), times = 8), rep(c(0,0,1,0,0), times = 8), rep(c(0,0,0,1,0), times = 7), rep(c(0,0,0,0,1), times = 7)), byrow=TRUE))

camst_matrix_1_2_2_18_item_1_3 <- rbind(matrix(nrow = 6, ncol = 5, data = rep(c(1,0,0,0,0),times=6), byrow=TRUE), matrix(nrow = 24, data = c(rep(c(0,1,0,0,0), times = 6), rep(c(0,0,1,0,0), times = 6), rep(c(0,0,0,1,0), times = 6), rep(c(0,0,0,0,1), times = 6)), byrow=TRUE))

camst_matrix_1_2_2_18_item_2_3 <- rbind(matrix(nrow = 12, ncol = 5, data = rep(c(1,0,0,0,0),times=12), byrow=TRUE), matrix(nrow = 12, ncol = 5, data = c(rep(c(0,1,0,0,0), times = 3), rep(c(0,0,1,0,0), times = 3), rep(c(0,0,0,1,0), times = 3), rep(c(0,0,0,0,1), times = 3)), byrow=TRUE))

transition_matrix_1_2_2 <- matrix(0, nrow = 5, ncol = 5); transition_matrix_1_2_2[1, 2:3] = 1; transition_matrix_1_2_2[2, 4:5] = 1; transition_matrix_1_2_2[3, 4:5] = 1

# 1-2-3 18 item
camst_matrix_1_2_3_18_item_1_6 <- rbind(matrix(nrow = 3, ncol = 6, data = rep(c(1,0,0,0,0,0),times=3), byrow=TRUE), matrix(nrow = 37, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 8), rep(c(0,0,1,0,0,0), times = 8), rep(c(0,0,0,1,0,0), times = 7), rep(c(0,0,0,0,1,0), times = 7), rep(c(0,0,0,0,0,1), times = 7)), byrow=TRUE))

camst_matrix_1_2_3_18_item_1_3 <- rbind(matrix(nrow = 6, ncol = 6, data = rep(c(1,0,0,0,0,0), times = 6), byrow=TRUE), matrix(nrow = 30, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 6), rep(c(0,0,1,0,0,0), times = 6), rep(c(0,0,0,1,0,0), times = 6), rep(c(0,0,0,0,1,0), times = 6), rep(c(0,0,0,0,0,1), times = 6)), byrow=TRUE))

camst_matrix_1_2_3_18_item_2_3 <- rbind(matrix(nrow = 12, ncol = 6, data = rep(c(1,0,0,0,0,0),times = 12), byrow=TRUE), matrix(nrow = 15, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 3), rep(c(0,0,1,0,0,0), times = 3), rep(c(0,0,0,1,0,0), times = 3), rep(c(0,0,0,0,1,0), times = 3), rep(c(0,0,0,0,0,1), times = 3)), byrow=TRUE))

transition_matrix_1_2_3 <- matrix(0, nrow = 6, ncol = 6); transition_matrix_1_2_3[1, 2:3] = 1; transition_matrix_1_2_3[2, 4:5] = 1; transition_matrix_1_2_3[3, 5:6] = 1

# 1-3-3 18 item
camst_matrix_1_3_3_18_item_1_6 <- rbind(matrix(nrow = 3, ncol = 7, data = rep(c(1,0,0,0,0,0,0), times = 3), byrow=TRUE), matrix(nrow = 45, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 8), rep(c(0,0,1,0,0,0,0), times = 8), rep(c(0,0,0,1,0,0,0), times = 8), rep(c(0,0,0,0,1,0,0), times = 7), rep(c(0,0,0,0,0,1,0), times = 7), rep(c(0,0,0,0,0,0,1), times = 7)), byrow=TRUE))

camst_matrix_1_3_3_18_item_1_3 <- rbind(matrix(nrow = 6, ncol = 7, data = rep(c(1,0,0,0,0,0,0), times = 6), byrow=TRUE), matrix(nrow = 36, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 6), rep(c(0,0,1,0,0,0,0), times = 6), rep(c(0,0,0,1,0,0,0), times = 6), rep(c(0,0,0,0,1,0,0), times = 6), rep(c(0,0,0,0,0,1,0), times = 6), rep(c(0,0,0,0,0,0,1), times = 6)), byrow=TRUE))

camst_matrix_1_3_3_18_item_2_3 <- rbind(matrix(nrow = 12, ncol = 7, data = rep(c(1,0,0,0,0,0, 0), times = 12), byrow=TRUE), matrix(nrow = 18, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 3), rep(c(0,0,1,0,0,0,0), times = 3), rep(c(0,0,0,1,0,0,0), times = 3), rep(c(0,0,0,0,1,0,0), times = 3), rep(c(0,0,0,0,0,1,0), times = 3), rep(c(0,0,0,0,0,0,1), times = 3)), byrow=TRUE))

transition_matrix_1_3_3 <- matrix(0, nrow = 7, ncol = 7); transition_matrix_1_3_3[1, 2:4] = 1; transition_matrix_1_3_3[2, 5:6] = 1; transition_matrix_1_3_3[3, 5:7] = 1; transition_matrix_1_3_3[4, 6:7] = 1

##### 30 item matrices #####
# 1-2-2 30 item
camst_matrix_1_2_2_30_item_1_6 <- rbind(matrix(nrow = 5, ncol = 5, data = rep(c(1,0,0,0,0), times = 5), byrow=TRUE), matrix(nrow = 50, ncol = 5, data = c(rep(c(0,1,0,0,0), times = 13), rep(c(0,0,1,0,0), times = 13), rep(c(0,0,0,1,0), times = 12), rep(c(0,0,0,0,1), times = 12)), byrow=TRUE))

camst_matrix_1_2_2_30_item_1_3 <- rbind(matrix(nrow = 10, ncol = 5, data = rep(c(1,0,0,0,0), times = 10), byrow=TRUE), matrix(nrow = 40, ncol = 5, data = c(rep(c(0,1,0,0,0), times = 10), rep(c(0,0,1,0,0), times = 10), rep(c(0,0,0,1,0), times = 10), rep(c(0,0,0,0,1), times = 10)), byrow=TRUE))

camst_matrix_1_2_2_30_item_2_3 <- rbind(matrix(nrow = 20, ncol = 5, data = rep(c(1,0,0,0,0), times = 20), byrow=TRUE), matrix(nrow = 20, ncol = 5, data = c(rep(c(0,1,0,0,0), times = 5), rep(c(0,0,1,0,0), times = 5), rep(c(0,0,0,1,0), times = 5), rep(c(0,0,0,0,1), times = 5)), byrow=TRUE))

# 1-2-3 30 item
camst_matrix_1_2_3_30_item_1_6 <- rbind(matrix(nrow = 5, ncol = 6, data = rep(c(1,0,0,0,0,0),times = 5), byrow=TRUE), matrix(nrow = 62, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 13), rep(c(0,0,1,0,0,0), times = 13), rep(c(0,0,0,1,0,0), times = 12), rep(c(0,0,0,0,1,0), times = 12), rep(c(0,0,0,0,0,1), times = 12)), byrow=TRUE))

camst_matrix_1_2_3_30_item_1_3 <- rbind(matrix(nrow = 10, ncol = 6, data = rep(c(1,0,0,0,0,0),times = 10), byrow=TRUE), matrix(nrow = 50, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 10), rep(c(0,0,1,0,0,0), times = 10), rep(c(0,0,0,1,0,0), times = 10), rep(c(0,0,0,0,1,0), times = 10), rep(c(0,0,0,0,0,1), times = 10)), byrow=TRUE))

camst_matrix_1_2_3_30_item_2_3 <- rbind(matrix(nrow = 20, ncol = 6, data = rep(c(1,0,0,0,0,0),times = 20), byrow=TRUE), matrix(nrow = 25, ncol = 6, data = c(rep(c(0,1,0,0,0,0), times = 5), rep(c(0,0,1,0,0,0), times = 5), rep(c(0,0,0,1,0,0), times = 5), rep(c(0,0,0,0,1,0), times = 5), rep(c(0,0,0,0,0,1), times = 5)), byrow=TRUE))

# 1-3-3 30 item
camst_matrix_1_3_3_30_item_1_6 <- rbind(matrix(nrow = 5, ncol = 7, data = rep(c(1,0,0,0,0,0,0), times = 5), byrow=TRUE), matrix(nrow = 75, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 13), rep(c(0,0,1,0,0,0,0), times = 13), rep(c(0,0,0,1,0,0,0), times = 13), rep(c(0,0,0,0,1,0,0), times = 12), rep(c(0,0,0,0,0,1,0), times = 12), rep(c(0,0,0,0,0,0,1), times = 12)), byrow=TRUE))

camst_matrix_1_3_3_30_item_1_3 <- rbind(matrix(nrow = 10, ncol = 7, data = rep(c(1,0,0,0,0,0,0), times = 10), byrow=TRUE), matrix(nrow = 60, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 10), rep(c(0,0,1,0,0,0,0), times = 10), rep(c(0,0,0,1,0,0,0), times = 10), rep(c(0,0,0,0,1,0,0), times = 10), rep(c(0,0,0,0,0,1,0), times = 10), rep(c(0,0,0,0,0,0,1), times = 10)), byrow=TRUE))

camst_matrix_1_3_3_18_item_2_3 <- rbind(matrix(nrow = 10, ncol = 7, data = rep(c(1,0,0,0,0,0,0), times = 20), byrow=TRUE), matrix(nrow = 30, ncol = 7, data = c(rep(c(0,1,0,0,0,0,0), times = 5), rep(c(0,0,1,0,0,0,0), times = 5), rep(c(0,0,0,1,0,0,0), times = 5), rep(c(0,0,0,0,1,0,0), times = 5), rep(c(0,0,0,0,0,1,0), times = 5), rep(c(0,0,0,0,0,0,1), times = 5)), byrow=TRUE))
