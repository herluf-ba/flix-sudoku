mod Sudoku {
    /// A sudoku board. 
    /// Always consist of 81 integers so we can use vectors to store it
    /// This makes it easier and faster to retrieve cells
    type alias Board = Vector[Vector[Int32]]

    // A helper for turning a vector into a vector of groups of size n
    def grouped(n: Int32, l: Vector[a]): Vector[Vector[a]] = 
        Vector.range(0, n) |> 
        Vector.map(
            i -> Vector.slice(start = i * n, end = i * n + n, l)
        )

    /// Pretty printing for Boards
    pub def display(s: Board): String = 
        let middle = s |>
            Vector.map(r -> r |> 
              grouped(3) |> 
              Vector.map(x -> " " + Vector.join(" ", x) + " ")
            ) |> 
            Vector.map(x -> "|" + Vector.join("|", x) + "|") |>
            grouped(3) |>
            Vector.map(Vector.join("\n")) |>
            Vector.join("\n+-------+-------+-------+\n");
        "\n+-------+-------+-------+\n" + middle + "\n+-------+-------+-------+\n"

    /// Parses a string of 81 numbers into a Board 
    pub def from_string(s: String): Result[String, Board] = 
        // TODO: check that s is only digits
      if (String.length(s) != 81) {
        Result.Err("cannot parse '${s}'")
      } else {
        let numbers = 
          String.split(regex="", s) |> 
          List.map(x -> x |> Int32.fromString |> Option.getWithDefault(0)) |> 
          List.toVector;
          
        Result.Ok(Sudoku.grouped(9, numbers)) 
      }

    /// Gets a row from a board
    def get_row(row: Int32, board: Board): Vector[Int32] = 
        board |> Vector.get((row |> Int32.max(0)) |> Int32.min(8))

    /// Gets a column from a board
    def get_column(column: Int32, board: Board): Vector[Int32] = 
        let c = (column |> Int32.max(0)) |> Int32.min(8);
        foreach (row <- board) 
            yield row |> Vector.get(c)

   
    /// Gets the 3x3 box that contains the cell at (row, column) 
    // row and column must be an integer in [0..8]
    def get_box(row: Int32, column: Int32, board: Board): Vector[Int32] =
        let box_x = (row / 3 |> Int32.max(0)) |> Int32.min(2);
        let box_y = (column / 3 |> Int32.max(0)) |> Int32.min(2);
        let xs = List.range(box_x * 3, box_x * 3 + 3);
        let ys = List.range(box_y * 3, box_y * 3 + 3);

        foreach (x <- xs; y <- ys)  yield board |> Vector.get(x) |> Vector.get(y)
        

    /// Checks if value is valid at (x, y)
    def validate(x: Int32, y: Int32, board: Board, value: Int32): Bool = 
        let contains_value = Vector.memberOf(value);
        let (row, column, box) = (
            Sudoku.get_row(x, board), 
            Sudoku.get_column(y, board), 
            Sudoku.get_box(x, y, board)
        );

        not contains_value(row) and not contains_value(column) and not contains_value(box)

    /// solves the sudoku
    pub def solve_puzzle(board: Board): Option[Board] \ IO = 
        def loop(b: Board, x: Int32, y: Int32) =
            if (y > 8) 
                // reach the end of board with all valid fields 
                // so we can return finished sudoku
                Some(b)
            else if (x > 8)
                // End of row, need to continue on next row
                loop(b, 0, y + 1)
            else if (b |> Vector.get(x) |> Vector.get(y) != 0)
                // this cell was prefilled, so skip it 
                loop(b, x + 1, y)
            else {
                // the cell needs to be filled, try to proceed with all valid values
                List.range(1, 10) |> 
                List.map(v -> {
                    if (not Sudoku.validate(x, y, b, v)) None else {
                        let b_with_v = Vector.update(x, Vector.update(y, v, Vector.get(x, b)), b);
                        loop(b_with_v, x + 1, y)    
                    } 
                }) |> 
                List.find(v -> not Option.isEmpty(v)) |> Option.flatten
            };

        loop(board, 0, 0) 

    /////// TESTS ///////
    def test_sudoku(): Sudoku.Board = Vector#{
        Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{9, 8, 7, 6, 5, 4, 3, 2, 1},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0},
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0}
    }

    @test
    def default_from_string(): Bool = Assert.eq(
        Result.Ok(test_sudoku()), 
        Sudoku.from_string("123456789000000000987654321000000000000000000000000000000000000000000000000000000")
    )

    @test
    def get_first_row(): Bool = Assert.eq(
        Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9}, 
        Sudoku.get_row(0, test_sudoku())
    )

    @test
    def get_second_row(): Bool = Assert.eq(
        Vector#{0, 0, 0, 0, 0, 0, 0, 0, 0}, 
        Sudoku.get_row(1, test_sudoku())
    )

    @test
    def get_first_column(): Bool = Assert.eq(
        Vector#{1, 0, 9, 0, 0, 0, 0, 0, 0}, 
        Sudoku.get_column(0, test_sudoku())
    )

    @test
    def get_second_column(): Bool = Assert.eq(
        Vector#{2, 0, 8, 0, 0, 0, 0, 0, 0}, 
        Sudoku.get_column(1, test_sudoku())
    )

     @test
    def get_first_box(): Bool = Assert.eq(
        Vector#{1, 2, 3, 0, 0, 0, 9, 8, 7}, 
        Sudoku.get_box(0, 0, test_sudoku())
    )

    @test
    def get_second_box(): Bool = Assert.eq(
        Vector#{4, 5, 6, 0, 0, 0, 6, 5, 4}, 
        Sudoku.get_box(0, 3, test_sudoku())
    )

    @test
    def valididate_valid_value(): Bool = Assert.eq(
        true, 
        Sudoku.validate(1, 0, test_sudoku(), 6)
    )
    
    @test
    def valididate_invalid_value(): Bool = Assert.eq(
        false, 
        Sudoku.validate(0, 0, test_sudoku(), 3)
    )
}

