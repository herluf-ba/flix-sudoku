use Sudoku;
def main(): Unit \ IO =
    let file = "sudoku_full.txt";

    match File.readLines(file) {
        case Err(msg)   => println("could not read '${file}': ${msg}")
        case Ok(lines)  => {
          let unsolved = lines |> 
            // Parse and try to solve each soduku
            List.map(s -> s |> Sudoku.from_string |> Result.map(Sudoku.solve_puzzle)) |> 
            // Extract all unsolvable sudokus
            List.zip(lines) |> 
            List.filter(match (_, r) -> Result.isErr(r)) |>
            List.map(match (s, _) ->  "could not solve ${s}");

          if (List.length(unsolved) == 0) 
            // Boast about sudoku solving capabilities
            println("solved ${List.length(lines)} sudokus")
          else 
            // Admit defeat and report unsolvable sudokus
            unsolved |> List.forEach(println)
        }
    }