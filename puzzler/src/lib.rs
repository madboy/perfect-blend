pub fn blend_colors(c: [i32; 3], n: [i32; 3]) -> [i32; 3] {
    [(c[0] + n[0]) / 2,
    (c[1] + n[1]) / 2,
    (c[2] + n[2]) / 2]
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

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn blend_white_and_grey() {
        let r = blend_colors([255, 255, 255], [100, 100, 100]);
        assert_eq!([177, 177, 177], r);
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
}
