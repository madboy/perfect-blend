local test_puzzle_solver = {}
local t = require("testing")
local ps = require("puzzle_solver")

function test_puzzle_solver.test_solvable()
    local result = ps.solvable({"@", 1, 1, 1, "e"})
    return t.assert_equal(true, result)
end

function test_puzzle_solver.test_empty_list_not_solvable()
    local result = ps.solvable({})
    return t.assert_equal(false, result)
end

t.run_tests(test_puzzle_solver)

return test_puzzle_solver
