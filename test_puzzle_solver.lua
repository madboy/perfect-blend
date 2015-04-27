local test_puzzle_solver = {}
local t = require("testing")
local ps = require("puzzle_solver")

function test_puzzle_solver.test_solvable()
    local player = {r=255, g=255, b=255}
    local result = ps.solvable({"@", 2, 1, 1, 1, "e"}, 6, player)
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_empty_list_not_solvable()
    local result = ps.solvable({}, 0)
    return t.assert_equal(false, result)
end

function test_puzzle_solver.test_size_mismatch()
    local result = ps.solvable({1, 1, 1}, 2)
    return t.assert_equal(false, result)
end

t.run_tests(test_puzzle_solver)

return test_puzzle_solver
