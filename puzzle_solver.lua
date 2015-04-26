local puzzle_solver = {}

function puzzle_solver.solvable(grid)
    if next(grid) == nil then
        return false
    end
    return false -- at the moment we cannot determin if anything is solvable
end

return puzzle_solver
