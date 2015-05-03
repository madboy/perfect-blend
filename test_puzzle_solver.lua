local test_puzzle_solver = {}
local t = require("testing")
local ps = require("puzzle_solver")

function test_puzzle_solver.test_solvable()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 1, 1, 1, 1, "e"}, 6, player)
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_solvable_two_rows()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 1, 1, 1, 1, 1,
                                2, 2, 2, 1, 1, "e"}, 6, player)
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_solvable_back_and_forth()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 2, 1, 1, 1, "e"}, 6, player)
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_walk_back_and_forth2()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 1, 1, 1, "e"}, 5, player)
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_unsolvable()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 2, 2, 2, "e"}, 5, player)
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_empty_list_not_solvable()
    local result = ps.solvable({}, 0)
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_size_mismatch()
    local result = ps.solvable({1, 1, 1}, 2)
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_row_length_mismatch()
    local grid = {1,2,3,4,5,6,7,8}
    local result = ps.solvable(grid, 5, {})
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_invalid_tiles()
    local grid = {"@", 1, 34}
    local result = ps.solvable(grid, 3, {})
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_single_row_grid()
    local grid = {1,1,1}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({11,12,13}, numbers) and
           t.assert_equal({12}, describer[11]) and
           t.assert_equal({11, 13}, describer[12]) and
           t.assert_equal({12}, describer[13])
end

function test_puzzle_solver.test_numbering()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({11,12,13,21,22,23,31,32,33}, numbers)
end

function test_puzzle_solver.test_top_left_corner()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({12, 21}, describer[11])
end

function test_puzzle_solver.test_top_right_corner()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({12, 23}, describer[13])
end

function test_puzzle_solver.test_bottom_left_corner()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({32,21}, describer[31])
end

function test_puzzle_solver.test_bottom_right_corner()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({32,23}, describer[33])
end

function test_puzzle_solver.test_left_edge_middle()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({22, 11, 31}, describer[21])
end

function test_puzzle_solver.test_right_edge_middle()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({22, 13, 33}, describer[23])
end

function test_puzzle_solver.test_top_middle()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({11, 13, 22}, describer[12])
end

function test_puzzle_solver.test_middle_middle()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({21, 23, 12, 32}, describer[22])
end

function test_puzzle_solver.test_bottom_middle()
    local grid = {1,1,1,2,2,2,3,3,3}
    local numbers, describer = ps.getGridNumbers(grid, 3)
    return t.assert_equal({31, 33, 22}, describer[32])
end
t.run_tests(test_puzzle_solver)

return test_puzzle_solver
