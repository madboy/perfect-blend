local test_puzzle_solver = {}
local t = require("testing")
local ps = require("puzzle_solver")

function test_puzzle_solver.test_solvable()
    return t.assert_equal(true, ps.solvable({}))
end

t.run_tests(test_puzzle_solver)

return test_puzzle_solver
