use std::collections::HashMap;

#[derive(Debug)]
pub struct Tile {
    name: char,
    color: [i32; 3],
    paths: Vec<i32>
}

impl Tile {
    fn new(name: char, color: [i32; 3], paths: Vec<i32>) -> Tile {
        Tile { name: name, color: color, paths: paths}
    }
}

pub fn blend_colors(c: [i32; 3], n: [i32; 3]) -> [i32; 3] {
    [(c[0] + n[0]) / 2,
    (c[1] + n[1]) / 2,
    (c[2] + n[2]) / 2]
}

pub fn abs(v: i32) -> i32 {
    if v < 0 {
        -v
    } else {
        v
    }
}

pub fn within_limit(v1: i32, v2: i32) -> bool {
    abs(v1-v2) < 10
}

pub fn colors_match(c1: [i32; 3], c2: [i32; 3]) -> bool {
    within_limit(c1[0], c2[0]) &&
    within_limit(c1[1], c2[1]) &&
    within_limit(c1[2], c2[2])
}

pub fn grid_numbering() -> [i32; 25] {
    let mut a = [0; 25];
    let mut row = 1;
    let mut col = 1;
    for i in 0..25 {
        if col > 5 {
            col = 1;
            row += 1;
        }
        let number = col + 10*row;
        a[i] = number;
        col += 1;
    }
    return a;
}

pub fn get_paths(p: i32) -> Vec<i32> {
    let mut paths = Vec::new();
    if (p % 10) == 1 {
        // left edge
        paths.push(p+1);
    } else if (p % 10) == 5 {
        // right edge
        paths.push(p-1);
    } else {
        paths.push(p-1);
        paths.push(p+1);
    }
    if p < 20 {
        // first row
        paths.push(p+10);
    } else if p > 50 {
        // last row
        paths.push(p-10);
    } else {
        paths.push(p-10);
        paths.push(p+10);
    }
    return paths;
}

pub fn create_level(grid: [i32; 25], keys: [char; 25], colors: HashMap<char, [i32; 3]>) -> HashMap<i32, Tile> {
    let mut level: HashMap<i32, Tile> = HashMap::new();
    for i in 0..25 {
        let name = keys[i];
        level.insert(grid[i], Tile::new(name, colors[&name], get_paths(grid[i])));
    }
    return level;
}

pub fn exit_in_path(exit: i32, paths: &Vec<i32>) -> (bool, i32) {
    for path in paths {
        if *path == exit {
            return (true, *path)
        }
    }
    return (false, -1);
}

pub fn get_next_step(position: i32, pcolor: [i32; 3], exit: i32, level: HashMap<i32, Tile>) -> i32 {
    let paths = &level[&position].paths;
    let (exit, next) = exit_in_path(exit, paths);
    if exit {
        return next;
    }
    return -1;
}

#[cfg(test)]
mod test {
    use super::*;
    use std::collections::HashMap;

    fn setup_colors() -> HashMap<char, [i32; 3]> {
        let mut colors: HashMap<char, [i32; 3]> = HashMap::new();
        colors.insert('e', [160, 255, 32]);
        colors.insert('f', [160, 255, 32]);
        colors.insert('g', [255, 255, 0]);
        colors.insert('@', [255, 255, 255]);
        colors.insert('s', [244, 62, 113]);
        colors.insert('r', [255, 255, 255]);
        return colors;
    }

    fn setup_keys() -> [char; 25] {
        ['e', 'e', 'g', 'g', 'g',
        'g', 'g', 'g', 'g', 'g',
        'g', 'g', 'g', 'g', 'g',
        'g', 'g', 'g', 'g', 'g',
        'g', 'g', 'g', 'g', 'g']
    }

    fn setup_level() -> HashMap<i32, Tile> {
        let grid = grid_numbering();
        let keys = setup_keys();
        let colors = setup_colors();
        let level = create_level(grid, keys, colors);
        return level;
    }

    #[test]
    fn blend_white_and_grey() {
        let r = blend_colors([255, 255, 255], [100, 100, 100]);
        assert_eq!([177, 177, 177], r);
    }

    #[test]
    fn abs_for_negative() {
        let r = abs(-10);
        assert_eq!(10, r);
    }

    #[test]
    fn abs_for_positive() {
        let r = abs(2);
        assert_eq!(2, r);
    }

    #[test]
    fn abs_for_zero() {
        let r = abs(0);
        assert_eq!(0, r)
    }

    #[test]
    fn within_the_allowed_limit() {
        let r = within_limit(100, 109);
        assert_eq!(true, r);
    }

    #[test]
    fn within_the_allowed_limit2() {
        let r = within_limit(100, 91);
        assert_eq!(true, r);
    }

    #[test]
    fn outside_limit() {
        let r = within_limit(66, 83);
        assert_eq!(false, r);
    }

    #[test]
    fn mathching_colors() {
        let r = colors_match([120, 130, 140], [125, 125, 143]);
        assert_eq!(true, r);
    }

    #[test]
    fn mismathching_colors() {
        let r = colors_match([115, 130, 140], [125, 125, 143]);
        assert_eq!(false, r);
    }

    #[test]
    fn create_grid() {
        let grid = grid_numbering();
        assert_eq!([11,12,13,14,15,
                   21,22,23,24,25,
                   31,32,33,34,35,
                   41,42,43,44,45,
                   51,52,53,54,55],
                   grid)
    }

    #[test]
    fn get_upper_left_paths() {
        let r = get_paths(11);
        let expected = vec![12,21];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_upper_right_paths() {
        let r = get_paths(15);
        let expected = vec![14,25];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_lower_left_paths() {
        let r = get_paths(51);
        let expected = vec![52, 41];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_lower_right_paths() {
        let r = get_paths(55);
        let expected = vec![54, 45];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_left_edge_paths() {
        let r = get_paths(21);
        let expected = vec![22,11,31];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_right_edge_paths() {
        let r = get_paths(35);
        let expected = vec![34,25,45];
        assert_eq!(expected, r);
    }

    #[test]
    fn get_middle_paths() {
        let r = get_paths(43);
        let expected = vec![42,44,33,53];
        assert_eq!(expected, r);
    }

    #[test]
    fn create_a_level_with_lot_of_ground() {
        let grid = grid_numbering();
        let keys: [char; 25] = ['e', 'g', 'g', 'g', 'g',
                                'g', 'g', 'g', 'g', 'g',
                                'g', 'g', 'g', 'g', 'g',
                                'g', 'g', 'g', 'g', 'g',
                                'g', 'g', 'g', 'g', 'g'];
        let colors = setup_colors();
        let level = create_level(grid, keys, colors);
        assert_eq!(level[&11].name, 'e');
        assert_eq!(level[&11].color, [160, 255, 32]);
        assert_eq!(level[&11].paths, [12,21]);
        assert_eq!(level[&44].name, 'g');
        assert_eq!(level[&44].paths, [43, 45, 34, 54]);
    }

    #[test]
    fn get_next_step_exit() {
        let level = setup_level();
        let next = get_next_step(11, [255, 255, 255], 12, level);
        assert_eq!(next, 12);
    }
}
