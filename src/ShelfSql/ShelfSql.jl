using SQLite: DB
using DBInterface
using DataFrames
include("../AbstractShelf/AbstractShelf.jl")
mutable struct ShelfSql <: AbstractShelf
    db::DB
    table::String
    filename::String
    primary_key::Union{Tuple, String}
end

include("baseFunction.jl")

"""
    open!(filename::String, table::String)
Open a given sqlite table from a given filename in a Shelf object

If the file don't exist an error is thrown

"""
function open!(filename::String, table::String)
    if isfile(filename)
        db = DB(filename)
        primary_key = primary_key_finder(db, table)
        return ShelfSql(db, table, filename, primary_key)
    else
        error("File $filename not found")
    end
end


"""
    primary_key_finder(db, table)

Find the primary of a given table.

"""
function primary_key_finder(db, table)
    primary_key = (DBInterface.execute(db, "SELECT l.name FROM pragma_table_info(?) as l WHERE l.pk <> 0", [table]) |>
                      DataFrame).name
    if length(primary_key) == 0
        error("No primary key found in table $table")
    elseif length(primary_key) == 1
        return primary_key[1]
    end
    return Tuple(primary_key)
end



# db = DB("src/ShelfSql/card.s3db")
db = open!("src/ShelfSql/card.s3db", "card")
# value = (number=4000007704518267, pin=3000, balance=111)
# df = copy.(eachrow((DBInterface.execute(db, "select (id, number) from card") |> DataFrame))) |> x -> values.(x)
# select(df, ("id", )...)
s = keys(db)

db[s[3]]
(1,) in db
# db[9] = (number=4000007704518277, pin=3000, balance=111)
# length(db)
# 2 in db
