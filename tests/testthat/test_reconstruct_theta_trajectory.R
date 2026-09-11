context("Testing reconstruct_theta_trajectory")

expected_cols = c("item_index", "item_name", "module", "theta", "sem",
                  "is_update", "segment_type", "point_type")

test_that("CAT trajectory has one update per item and matches the final estimate", {
  result = make_small_cat_result()
  traj = reconstruct_theta_trajectory(result, 1)

  expect_true(all(expected_cols %in% colnames(traj)))
  expect_equal(nrow(traj), sum(!is.na(result@final.items.seen[1, ])))
  expect_true(all(traj$is_update))
  expect_true(all(traj$segment_type == "cat"))
  expect_true(all(is.finite(traj$theta)))
  expect_true(all(is.finite(traj$sem)))

  # method == final.theta.method by default, so no separate "final" row and
  # the last reconstructed point should equal the object's own final estimate
  expect_true(all(traj$point_type == "provisional"))
  expect_equal(tail(traj$theta, 1), result@final.theta.estimate[1],
              tolerance = 1e-6)
})

test_that("MST trajectory only updates at the last item of each module", {
  result = make_small_mst_result()
  traj = reconstruct_theta_trajectory(result, 1)

  expect_true(all(expected_cols %in% colnames(traj)))
  expect_true(all(traj$segment_type == "mst"))

  n_stages_seen = sum(!is.na(result@modules.seen[1, ]))
  expect_equal(sum(traj$is_update), n_stages_seen)

  # theta must be constant within each module (only recomputed once, at
  # the module's last item)
  for (mod in unique(traj$module)) {
    mod_theta = traj$theta[traj$module == mod]
    expect_equal(length(unique(mod_theta)), 1)
  }

  expect_equal(tail(traj$theta[traj$is_update], 1),
              result@final.theta.estimate[1], tolerance = 1e-6)
})

test_that("MAT trajectory has a CAT segment then an MST segment", {
  result = make_small_mat_result()
  traj = reconstruct_theta_trajectory(result, 1)

  expect_true(all(expected_cols %in% colnames(traj)))
  expect_true("cat" %in% traj$segment_type)
  expect_true("mst" %in% traj$segment_type)

  # CAT segment (routing stage) updates every item
  cat_rows = traj[traj$segment_type == "cat", ]
  expect_true(all(cat_rows$is_update))

  # CAT items must precede MST items in administration order
  expect_true(max(cat_rows$item_index) < min(traj$item_index[traj$segment_type == "mst"]))
})

test_that("HAT trajectory has an MST segment then a CAT segment (reversed order)", {
  result = make_small_hat_result()
  traj = reconstruct_theta_trajectory(result, 1)

  expect_true(all(expected_cols %in% colnames(traj)))
  expect_true("cat" %in% traj$segment_type)
  expect_true("mst" %in% traj$segment_type)

  cat_rows = traj[traj$segment_type == "cat", ]
  mst_rows = traj[traj$segment_type == "mst", ]

  # reversed from MAT: MST items come first, CAT items last
  expect_true(max(mst_rows$item_index) < min(cat_rows$item_index))

  # CAT stage (final) updates every item, using MST+CAT combined -- so the
  # very last CAT-phase theta should equal the object's own final estimate
  expect_true(all(cat_rows$is_update))
  expect_equal(tail(cat_rows$theta, 1), result@final.theta.estimate[1],
              tolerance = 1e-6)
})

test_that("a distinguishing final-point row is appended when final_theta_method differs", {
  result_same = make_small_cat_result(final_theta_method = NULL)
  traj_same = reconstruct_theta_trajectory(result_same, 1)
  expect_false("final" %in% traj_same$point_type)

  result_diff = make_small_cat_result(final_theta_method = "EAP")
  traj_diff = reconstruct_theta_trajectory(result_diff, 1)
  expect_true("final" %in% traj_diff$point_type)

  final_row = traj_diff[traj_diff$point_type == "final", ]
  expect_equal(nrow(final_row), 1)
  expect_equal(final_row$theta, result_diff@final.theta.estimate[1])
  expect_equal(final_row$sem, result_diff@final.theta.SEM[1])
  expect_true(final_row$is_update)
  # same x-position as the last provisional point
  expect_equal(final_row$item_index, tail(traj_diff$item_index[traj_diff$point_type == "provisional"], 1))
})

test_that("trajectories can be reconstructed for a second person independently", {
  result = make_small_cat_result(n_persons = 2)
  traj1 = reconstruct_theta_trajectory(result, 1)
  traj2 = reconstruct_theta_trajectory(result, 2)

  expect_false(identical(traj1$item_name, traj2$item_name))
  expect_equal(tail(traj2$theta, 1), result@final.theta.estimate[2], tolerance = 1e-6)
})
